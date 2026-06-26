// showcase.tsx — syntax sampler for stargum.nvim screenshots
import { useState, useEffect, useMemo, type FC } from "react";
import { z } from "zod";

const API_BASE = "https://api.example.com/v2" as const;
const MAX_RETRIES = 3;

type Status = "idle" | "loading" | "success" | "error";

interface Star {
	id: number;
	name: string;
	hue: `#${string}`;
	spectra: readonly string[];
	pulsar?: boolean;
}

const StarSchema = z.object({
	id: z.number().int().positive(),
	name: z.string().min(1),
	hue: z.string().regex(/^#[0-9a-f]{6}$/i),
});

/**
 * Fetch a star by id, retrying on transient failures.
 * @throws when the response shape is invalid
 */
async function fetchStar(id: number, signal?: AbortSignal): Promise<Star> {
	for (let attempt = 1; attempt <= MAX_RETRIES; attempt++) {
		const res = await fetch(`${API_BASE}/stars/${id}`, { signal });
		if (res.ok) {
			return StarSchema.parse(await res.json()) as Star;
		}
		console.warn(`attempt ${attempt} failed: ${res.status}`);
	}
	throw new Error(`star ${id} unreachable after ${MAX_RETRIES} tries`);
}

export const StarCard: FC<{ star: Star; onPick: (s: Star) => void }> = ({
	star,
	onPick,
}) => {
	const [status, setStatus] = useState<Status>("idle");
	const label = useMemo(
		() => (star.pulsar ? `★ ${star.name}` : star.name),
		[star],
	);

	useEffect(() => {
		const controller = new AbortController();
		setStatus("loading");
		fetchStar(star.id, controller.signal)
			.then(() => setStatus("success"))
			.catch(() => setStatus("error"));
		return () => controller.abort();
	}, [star.id]);

	return (
		<article className="star-card" data-status={status} style={{ color: star.hue }}>
			<h2>{label}</h2>
			<ul>
				{star.spectra.map((band, i) => (
					<li key={i}>{band}</li>
				))}
			</ul>
			<button disabled={status === "loading"} onClick={() => onPick(star)}>
				{status === "loading" ? "Loading…" : "Pick"}
			</button>
		</article>
	);
};
