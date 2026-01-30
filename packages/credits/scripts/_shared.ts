import { readFileSync } from "node:fs";

export type ArgValue = string | boolean;

export const parseArgs = () => {
  const args = process.argv.slice(2);
  const out: Record<string, ArgValue> = {};
  for (let i = 0; i < args.length; i++) {
    const key = args[i];
    if (!key.startsWith("--")) continue;
    const name = key.slice(2);
    const next = args[i + 1];
    if (!next || next.startsWith("--")) {
      out[name] = true;
      continue;
    }
    out[name] = next;
    i++;
  }
  return out;
};

export const loadJson = <T>(path: string): T => JSON.parse(readFileSync(path, "utf-8")) as T;

export async function graphql<T>(url: string, query: string, variables: Record<string, unknown>) {
  const headers: Record<string, string> = { "content-type": "application/json" };
  const secret = process.env.HASURA_GRAPHQL_ADMIN_SECRET || process.env.HASURA_ADMIN_SECRET;
  const role = process.env.HASURA_GRAPHQL_ROLE;
  if (secret) headers["x-hasura-admin-secret"] = secret;
  if (role) headers["x-hasura-role"] = role;

  const res = await fetch(url, {
    method: "POST",
    headers,
    body: JSON.stringify({ query, variables }),
  });
  const json = (await res.json()) as any;
  if (!res.ok || json.errors) {
    const details = JSON.stringify(json.errors ?? json, null, 2);
    throw new Error(`GraphQL error (${res.status}): ${details}`);
  }
  return json.data as T;
}

export async function detectQueryField(url: string, typeName: string) {
  const data = await graphql<{ __schema: { queryType: { fields: Array<{ name: string }> } } }>(
    url,
    "query Introspect { __schema { queryType { fields { name } } } }",
    {}
  );
  const fields = data.__schema.queryType.fields.map((f) => f.name);
  const exact = fields.find((name) => name === typeName);
  if (exact) return exact;
  const ci = fields.find((name) => name.toLowerCase() === typeName.toLowerCase());
  if (ci) return ci;
  const candidate = fields.find(
    (name) => name.toLowerCase().includes(typeName.toLowerCase()) && !name.endsWith("_aggregate") && !name.endsWith("_by_pk")
  );
  if (candidate) return candidate;
  throw new Error(`Could not find ${typeName} query field in GraphQL schema.`);
}

