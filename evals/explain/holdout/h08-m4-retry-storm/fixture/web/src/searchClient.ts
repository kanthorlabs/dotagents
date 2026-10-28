import { fetchJson } from "./http";
import type { Results } from "./types";

const TIMEOUT_MS = 2000;
const MAX_ATTEMPTS = 3;

export async function search(query: string): Promise<Results> {
  let lastError: unknown;
  for (let attempt = 1; attempt <= MAX_ATTEMPTS; attempt++) {
    try {
      return await fetchJson<Results>(`/api/search?q=${encodeURIComponent(query)}`, {
        timeoutMs: TIMEOUT_MS,
      });
    } catch (error) {
      lastError = error;
    }
  }
  throw lastError;
}
