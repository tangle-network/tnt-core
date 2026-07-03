/**
 * ABI parameter spec for `Types.BlueprintDefinition` — the payload of
 * `BlueprintDefinitionRecorded.encodedDefinition` (`abi.encode(definition)`).
 *
 * Extracted from `bindings/abi/ITangleFull.json` (`getBlueprintDefinition`
 * outputs); regenerate from there whenever the struct changes on-chain, and
 * keep `keccak256(encodedDefinition) == blueprintDefinitionHash(blueprintId)`
 * as the on-chain integrity anchor for any untrusted reader.
 */
export const BLUEPRINT_DEFINITION_ABI_PARAMETER = {
  "type": "tuple",
  "name": "definition",
  "components": [
    {
      "type": "string",
      "name": "metadataUri"
    },
    {
      "type": "bytes32",
      "name": "metadataHash"
    },
    {
      "type": "address",
      "name": "manager"
    },
    {
      "type": "uint32",
      "name": "masterManagerRevision"
    },
    {
      "type": "bool",
      "name": "hasConfig"
    },
    {
      "type": "tuple",
      "name": "config",
      "components": [
        {
          "type": "uint8",
          "name": "membership"
        },
        {
          "type": "uint8",
          "name": "pricing"
        },
        {
          "type": "uint32",
          "name": "minOperators"
        },
        {
          "type": "uint32",
          "name": "maxOperators"
        },
        {
          "type": "uint256",
          "name": "subscriptionRate"
        },
        {
          "type": "uint64",
          "name": "subscriptionInterval"
        },
        {
          "type": "uint256",
          "name": "eventRate"
        }
      ]
    },
    {
      "type": "tuple",
      "name": "metadata",
      "components": [
        {
          "type": "string",
          "name": "name"
        },
        {
          "type": "string",
          "name": "description"
        },
        {
          "type": "string",
          "name": "author"
        },
        {
          "type": "string",
          "name": "category"
        },
        {
          "type": "string",
          "name": "codeRepository"
        },
        {
          "type": "string",
          "name": "logo"
        },
        {
          "type": "string",
          "name": "website"
        },
        {
          "type": "string",
          "name": "license"
        },
        {
          "type": "string",
          "name": "profilingData"
        }
      ]
    },
    {
      "type": "tuple[]",
      "name": "jobs",
      "components": [
        {
          "type": "string",
          "name": "name"
        },
        {
          "type": "string",
          "name": "description"
        },
        {
          "type": "string",
          "name": "metadataUri"
        },
        {
          "type": "bytes",
          "name": "paramsSchema"
        },
        {
          "type": "bytes",
          "name": "resultSchema"
        }
      ]
    },
    {
      "type": "bytes",
      "name": "registrationSchema"
    },
    {
      "type": "bytes",
      "name": "requestSchema"
    },
    {
      "type": "tuple[]",
      "name": "sources",
      "components": [
        {
          "type": "uint8",
          "name": "kind"
        },
        {
          "type": "tuple",
          "name": "container",
          "components": [
            {
              "type": "string",
              "name": "registry"
            },
            {
              "type": "string",
              "name": "image"
            },
            {
              "type": "string",
              "name": "tag"
            }
          ]
        },
        {
          "type": "tuple",
          "name": "wasm",
          "components": [
            {
              "type": "uint8",
              "name": "runtime"
            },
            {
              "type": "uint8",
              "name": "fetcher"
            },
            {
              "type": "string",
              "name": "artifactUri"
            },
            {
              "type": "string",
              "name": "entrypoint"
            }
          ]
        },
        {
          "type": "tuple",
          "name": "native",
          "components": [
            {
              "type": "uint8",
              "name": "fetcher"
            },
            {
              "type": "string",
              "name": "artifactUri"
            },
            {
              "type": "string",
              "name": "entrypoint"
            }
          ]
        },
        {
          "type": "tuple",
          "name": "testing",
          "components": [
            {
              "type": "string",
              "name": "cargoPackage"
            },
            {
              "type": "string",
              "name": "cargoBin"
            },
            {
              "type": "string",
              "name": "basePath"
            }
          ]
        },
        {
          "type": "tuple[]",
          "name": "binaries",
          "components": [
            {
              "type": "uint8",
              "name": "arch"
            },
            {
              "type": "uint8",
              "name": "os"
            },
            {
              "type": "string",
              "name": "name"
            },
            {
              "type": "bytes32",
              "name": "sha256"
            }
          ]
        }
      ]
    },
    {
      "type": "uint8[]",
      "name": "supportedMemberships"
    }
  ]
} as const;
