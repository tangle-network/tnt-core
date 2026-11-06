"""Inspect the actual Cargo archive, then run a downstream generated-API consumer."""
import hashlib
import json
import pathlib
import re
import shutil
import subprocess
import sys
import tarfile
import tempfile
import tomllib

candidate = sys.argv[1]
run = lambda args: subprocess.check_output(args, text=True).strip()
head = run(['git', 'rev-parse', 'HEAD'])
subprocess.run(['git', 'diff', '--exit-code', candidate, '--', 'src', 'foundry.toml',
                'soldeer.lock', 'remappings.txt', 'Cargo.toml', 'Cargo.lock',
                'bindings/Cargo.toml', 'bindings/README.md', 'bindings/CHANGELOG.md'], check=True)
meta = json.loads(run(['cargo', 'metadata', '--no-deps', '--format-version', '1', '--locked']))
pkg = next(p for p in meta['packages'] if p['name'] == 'tnt-core-bindings')
archive = pathlib.Path(meta['target_directory']) / 'package' / f"{pkg['name']}-{pkg['version']}.crate"
assert archive.is_file(), archive
archive_sha = hashlib.sha256(archive.read_bytes()).hexdigest()
with tempfile.TemporaryDirectory(prefix='bindings-package-review-', dir=meta['target_directory']) as temp:
    temp = pathlib.Path(temp)
    with tarfile.open(archive) as tar:
        members = tar.getmembers()
        assert all((m.isfile() or m.isdir()) and not pathlib.PurePosixPath(m.name).is_absolute()
                   and '..' not in pathlib.PurePosixPath(m.name).parts for m in members)
        tar.extractall(temp, filter='data')
    extracted = temp / f"{pkg['name']}-{pkg['version']}"
    manifest = tomllib.loads((extracted / 'Cargo.toml').read_text())
    assert manifest['package']['name'] == pkg['name']
    assert manifest['package']['version'] == pkg['version']
    core_version = (extracted / 'TNT_CORE_VERSION').read_text().strip()
    vcs = json.loads((extracted / '.cargo_vcs_info.json').read_text())
    assert core_version == head, (core_version, head)
    assert vcs['git']['sha1'] == head, vcs
    assert vcs['path_in_vcs'] == 'bindings', vcs
    exported = (extracted / 'src/lib.rs').read_text()
    for name in ['ITangle', 'ITangleFull', 'ITangleJobs', 'TNT_CORE_VERSION']:
        assert name in exported, name
    abi_rows = {}
    for name in ['ITangle', 'ITangleFull']:
        artifact = json.loads((extracted / 'abi' / f'{name}.json').read_text())
        abi = artifact.get('abi', artifact) if isinstance(artifact, dict) else artifact
        calls = [x for x in abi if x.get('type') == 'function' and x.get('name') == 'submitJobFromQuote']
        assert sorted(len(x['inputs']) for x in calls) == [4, 5], (name, calls)
        gpu = next(x for x in calls if len(x['inputs']) == 5)['inputs'][-1]
        assert [(x['name'], x['type']) for x in gpu['components']] == [
            ('kind', 'uint8'), ('count', 'uint64'), ('gpuClass', 'bytes32'), ('durationSecs', 'uint64')]
        assert any(x.get('type') == 'event' and x.get('name') == 'JobGpuResourceCommitted' for x in abi)
        abi_rows[name] = [4, 5]
    manager = json.loads((extracted / 'abi/IBlueprintServiceManager.json').read_text())
    manager_abi = manager.get('abi', manager) if isinstance(manager, dict) else manager
    initializer_exported = any(x.get('name') == 'initializeBlueprintManager' for x in manager_abi)
    invocations = []
    call_names = {}
    for module in ['i_tangle', 'i_tangle_jobs']:
        source = (extracted / 'src/bindings' / f'{module}.rs').read_text()
        calls = dict(re.findall(r'pub struct (submitJobFromQuote(?:_\d+)?Call)\s*\{([^}]+)\}', source))
        assert len(calls) == 2, (module, list(calls))
        legacy = next(n for n, body in calls.items() if 'pub resource:' not in body)
        gpu = next(n for n, body in calls.items() if 'pub resource:' in body)
        call_names[module] = {'legacy': legacy, 'gpu': gpu}
        contract = 'ITangle' if module == 'i_tangle' else 'ITangleJobs'
        invocations.append(f'    check!(r#{module}, {contract}, {legacy}, {gpu});')
    client = temp / 'consumer'
    (client / 'src').mkdir(parents=True)
    alloy = manifest['dependencies']['alloy']['version']
    (client / 'Cargo.toml').write_text(f'''[package]
name = "independent-gpu-bindings-consumer"
version = "0.0.0"
edition = "2021"
[workspace]
[dependencies]
tnt-core-bindings = {{ path = {json.dumps(str(extracted))} }}
alloy = {{ version = {json.dumps(alloy)} }}
''')
    lock = extracted / 'Cargo.lock'
    shutil.copyfile(lock if lock.exists() else pathlib.Path('Cargo.lock'), client / 'Cargo.lock')
    # Each ABI module owns its generated call/type namespace; exercise both public surfaces.
    source = r'''
use alloy::primitives::{Address, Bytes, U256, keccak256};
use alloy::sol_types::{SolCall, SolStruct};
macro_rules! check {
    ($module:ident, $contract:ident, $legacy:ident, $gpu:ident) => {{
        use tnt_core_bindings::bindings::$module::Types;
        use tnt_core_bindings::bindings::$module::$contract as Contract;
        let quote = Types::SignedJobQuote {
            details: Types::JobQuoteDetails {
                requester: Address::repeat_byte(2), serviceId: 42, jobIndex: 3,
                price: U256::MAX, timestamp: 1, expiry: 3601, confidentiality: 0,
                inputsHash: keccak256(b"lease"),
            },
            signature: Bytes::from(vec![17; 65]), operator: Address::repeat_byte(1),
        };
        let old = Contract::$legacy { serviceId: 42, jobIndex: 3,
            inputs: Bytes::from_static(b"lease"), quotes: vec![quote.clone()] };
        let old_bytes = old.abi_encode();
        let decoded = Contract::$legacy::abi_decode_validate(&old_bytes).unwrap();
        assert_eq!(decoded.quotes[0].details.price, U256::MAX);
        assert_eq!(decoded.inputs.as_ref(), b"lease");
        let expected = keccak256(b"submitJobFromQuote(uint64,uint8,bytes,((address,uint64,uint8,uint256,uint64,uint64,uint8,bytes32),bytes,address)[])");
        assert_eq!(&old_bytes[..4], &expected[..4]);
        let gpu = Contract::$gpu { serviceId: 42, jobIndex: 3,
            inputs: Bytes::from_static(b"lease"), quotes: vec![quote],
            resource: Types::GpuResourceCommitment { kind: 5, count: 8,
                gpuClass: keccak256(b"nvidia-b200"), durationSecs: 3600 } };
        let bytes = gpu.abi_encode();
        let decoded = Contract::$gpu::abi_decode_validate(&bytes).unwrap();
        assert_eq!(decoded.quotes[0].details.price, U256::MAX);
        assert_eq!(decoded.resource.kind, 5);
        assert_eq!(decoded.resource.count, 8);
        assert_eq!(decoded.resource.gpuClass, keccak256(b"nvidia-b200"));
        assert_eq!(decoded.resource.durationSecs, 3600);
        assert_eq!(Types::GpuResourceCommitment::eip712_encode_type(),
            "GpuResourceCommitment(uint8 kind,uint64 count,bytes32 gpuClass,uint64 durationSecs)");
        let expected = keccak256(b"submitJobFromQuote(uint64,uint8,bytes,((address,uint64,uint8,uint256,uint64,uint64,uint8,bytes32),bytes,address)[],(uint8,uint64,bytes32,uint64))");
        assert_eq!(&bytes[..4], &expected[..4]);
    }};
}
fn main() {
__CALLS__
    assert_eq!(tnt_core_bindings::TNT_CORE_VERSION.trim(), "__HEAD__");
    println!("PUBLIC_PACKAGE_CONSUMER_OK legacy4 GPU5 exact_uint256 canonical_resource both_interfaces");
}
'''
    source = source.replace('__CALLS__', '\n'.join(invocations)).replace('__HEAD__', head)
    (client / 'src/main.rs').write_text(source)
    subprocess.run(['cargo', 'run', '--offline', '--quiet', '--manifest-path', str(client / 'Cargo.toml')], check=True)
    print('PACKAGE_REVIEW=' + json.dumps({'candidate': candidate, 'review_head': head,
        'package_sha256': archive_sha, 'compressed_bytes': archive.stat().st_size,
        'regular_files': sum(m.isfile() for m in members), 'source': core_version, 'vcs': vcs,
        'abis': abi_rows, 'generated_calls': call_names,
        'bsm_initializer_in_callback_interface': initializer_exported}, sort_keys=True))
