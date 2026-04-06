import {
  useEffect,
  useRef,
  useState,
} from "react";

import { cn } from "@/lib/utils";

import { trustedByLogos, type TrustedByLogo } from "./trustedByLogos";

type HomeLink = {
  label: string;
  href: string;
};

type HomePost = {
  slug: string;
  path: string;
  author: string;
  published_at: string;
  title: string;
  excerpt: string;
};

type HomeIndexProps = {
  title: string;
  subtitle: string;
  trustedBy: {
    heading: string;
    subtitle: string;
    fixedLogoNames: string[];
    rotationIntervalMs: number;
    transitionDurationMs: number;
    staggerDelayMs: number;
  };
  featuredPostsHeading: string;
  featuredPostsPath: string;
  featuredPostsEmpty: string;
  featuredPosts: HomePost[];
  links: {
    linkedin: HomeLink;
    calendar: HomeLink;
  };
};

type LogoSlot = {
  current: TrustedByLogo;
  phase: "visible" | "fading-out" | "fading-in";
};

const SLOT_VISIBILITY_CLASSNAMES = [
  "block",
  "hidden sm:block",
  "hidden lg:block",
];

function buildInitialTrustedByLogos(fixedLogoNames: string[]) {
  const preferred = fixedLogoNames
    .map(name => trustedByLogos.find(logo => logo.name === name))
    .filter((logo): logo is TrustedByLogo => Boolean(logo));
  const remaining = trustedByLogos.filter(
    logo => !preferred.some(preferredLogo => preferredLogo.name === logo.name),
  );

  return [...preferred, ...remaining].slice(0, 3);
}

function shuffleSlotIndexes(slotCount: number) {
  const indexes = Array.from({ length: slotCount }, (_, index) => index);

  for (let index = indexes.length - 1; index > 0; index -= 1) {
    const randomIndex = Math.floor(Math.random() * (index + 1));
    [indexes[index], indexes[randomIndex]] = [indexes[randomIndex], indexes[index]];
  }

  return indexes;
}

function pickNextTrustedByLogo(
  slotIndex: number,
  slots: LogoSlot[],
  rotatingLogos: TrustedByLogo[],
  reservedLogoNames: Set<string>,
) {
  const currentName = slots[slotIndex]?.current.name;
  const occupiedNames = new Set([
    ...slots.map(slot => slot.current.name),
    ...reservedLogoNames,
  ]);

  let candidates = rotatingLogos.filter(
    logo => logo.name !== currentName && !occupiedNames.has(logo.name),
  );

  if (candidates.length === 0) {
    candidates = rotatingLogos.filter(logo => logo.name !== currentName);
  }

  if (candidates.length === 0) {
    return null;
  }

  return candidates[Math.floor(Math.random() * candidates.length)];
}

function usePrefersReducedMotion() {
  const [prefersReducedMotion, setPrefersReducedMotion] = useState(false);

  useEffect(() => {
    const mediaQuery = window.matchMedia("(prefers-reduced-motion: reduce)");

    setPrefersReducedMotion(mediaQuery.matches);

    const handleChange = (event: MediaQueryListEvent) => {
      setPrefersReducedMotion(event.matches);
    };

    mediaQuery.addEventListener("change", handleChange);

    return () => {
      mediaQuery.removeEventListener("change", handleChange);
    };
  }, []);

  return prefersReducedMotion;
}

function TrustedBySection({
  heading,
  fixedLogoNames,
  rotationIntervalMs,
  transitionDurationMs,
  staggerDelayMs,
}: HomeIndexProps["trustedBy"]) {
  const initialLogos = buildInitialTrustedByLogos(fixedLogoNames);
  const rotatingLogos = trustedByLogos.filter(
    logo => !initialLogos.some(initialLogo => initialLogo.name === logo.name),
  );
  const [slots, setSlots] = useState<LogoSlot[]>(
    () =>
      initialLogos.map(logo => ({
        current: logo,
        phase: "visible",
      })),
  );
  const prefersReducedMotion = usePrefersReducedMotion();
  const slotsRef = useRef(slots);
  const rotatingLogosRef = useRef(rotatingLogos);
  const transitionDurationMsRef = useRef(transitionDurationMs);
  const reservedLogoNamesRef = useRef(new Set<string>());
  const rotationTimeoutIdsRef = useRef(new Set<number>());
  const phaseTimeoutIdsRef = useRef(new Set<number>());

  useEffect(() => {
    slotsRef.current = slots;
  }, [slots]);

  useEffect(() => {
    rotatingLogosRef.current = rotatingLogos;
  }, [rotatingLogos]);

  useEffect(() => {
    transitionDurationMsRef.current = transitionDurationMs;
  }, [transitionDurationMs]);

  const clearScheduledAnimations = () => {
    for (const timeoutId of rotationTimeoutIdsRef.current) {
      window.clearTimeout(timeoutId);
    }
    rotationTimeoutIdsRef.current.clear();

    for (const timeoutId of phaseTimeoutIdsRef.current) {
      window.clearTimeout(timeoutId);
    }
    phaseTimeoutIdsRef.current.clear();

    reservedLogoNamesRef.current.clear();
  };

  const runSlotTransition = (slotIndex: number) => {
    const currentSlots = slotsRef.current;
    const availableRotatingLogos = rotatingLogosRef.current;
    const currentSlot = currentSlots[slotIndex];

    if (!currentSlot || currentSlot.phase !== "visible" || availableRotatingLogos.length === 0) {
      return;
    }

    const reservedLogoNames = reservedLogoNamesRef.current;
    const nextLogo = pickNextTrustedByLogo(
      slotIndex,
      currentSlots,
      availableRotatingLogos,
      reservedLogoNames,
    );

    if (!nextLogo) {
      return;
    }

    reservedLogoNames.add(nextLogo.name);

    setSlots(previousSlots =>
      previousSlots.map((slot, index) =>
        index === slotIndex
          ? {
              ...slot,
              phase: "fading-out",
            }
          : slot,
      ),
    );

    const swapTimeoutId = window.setTimeout(() => {
      phaseTimeoutIdsRef.current.delete(swapTimeoutId);

      setSlots(previousSlots =>
        previousSlots.map((slot, index) =>
          index === slotIndex
            ? {
                current: nextLogo,
                phase: "fading-in",
              }
            : slot,
        ),
      );

      const settleTimeoutId = window.setTimeout(() => {
        phaseTimeoutIdsRef.current.delete(settleTimeoutId);
        reservedLogoNamesRef.current.delete(nextLogo.name);

        setSlots(previousSlots =>
          previousSlots.map((slot, index) =>
            index === slotIndex
              ? {
                  ...slot,
                  phase: "visible",
                }
              : slot,
          ),
        );
      }, transitionDurationMsRef.current);

      phaseTimeoutIdsRef.current.add(settleTimeoutId);
    }, transitionDurationMsRef.current);

    phaseTimeoutIdsRef.current.add(swapTimeoutId);
  };

  useEffect(() => {
    clearScheduledAnimations();

    if (prefersReducedMotion || rotatingLogos.length === 0) {
      return undefined;
    }

    const scheduleCycle = (delayMs: number) => {
      const timeoutId = window.setTimeout(() => {
        rotationTimeoutIdsRef.current.delete(timeoutId);
        const slotOrder = shuffleSlotIndexes(slots.length);

        slotOrder.forEach((slotIndex, orderIndex) => {
          const staggeredTimeoutId = window.setTimeout(() => {
            rotationTimeoutIdsRef.current.delete(staggeredTimeoutId);
            runSlotTransition(slotIndex);
          }, orderIndex * staggerDelayMs);

          rotationTimeoutIdsRef.current.add(staggeredTimeoutId);
        });

        scheduleCycle(rotationIntervalMs);
      }, delayMs);

      rotationTimeoutIdsRef.current.add(timeoutId);
    };

    scheduleCycle(rotationIntervalMs);

    return () => {
      clearScheduledAnimations();
    };
  }, [
    prefersReducedMotion,
    rotatingLogos.length,
    rotationIntervalMs,
    slots.length,
    staggerDelayMs,
  ]);

  return (
    <section className="mt-12" aria-label={heading}>
      <div className="space-y-5">
        <div>
          <p className="text-sm font-semibold uppercase tracking-[0.28em] text-muted-foreground">
            {heading}
          </p>
        </div>
        <div className="grid grid-cols-1 items-center gap-x-10 gap-y-6 sm:grid-cols-2 lg:grid-cols-3">
          {slots.map((slot, index) => (
            <div
              key={index}
              className={cn(
                "animate-in fade-in slide-in-from-bottom-2 duration-700 motion-reduce:animate-none",
                SLOT_VISIBILITY_CLASSNAMES[index] ?? "",
              )}
              style={{ animationDelay: `${index * 120}ms` }}
            >
              <img
                src={slot.current.src}
                alt=""
                aria-hidden="true"
                className={cn(
                  "h-[4.5rem] w-full object-contain object-left transition-opacity dark:invert",
                  slot.phase === "fading-out" ? "opacity-0" : "opacity-100",
                )}
                style={{ transitionDuration: `${transitionDurationMs}ms` }}
              />
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}

function ExternalLink({ link }: { link: HomeLink }) {
  return (
    <a
      href={link.href}
      target="_blank"
      rel="noreferrer"
      className="text-lg text-primary underline underline-offset-4 transition-colors hover:text-primary/80"
    >
      {link.label}
    </a>
  );
}

export default function HomeIndex({
  title,
  subtitle,
  trustedBy,
  featuredPostsHeading,
  featuredPostsPath,
  featuredPostsEmpty,
  featuredPosts,
  links,
}: HomeIndexProps) {
  return (
    <div className="mx-auto max-w-6xl px-4 py-10 sm:px-6 sm:py-14 lg:px-8">
      <section className="max-w-4xl space-y-6">
        <h1 className="max-w-3xl text-4xl font-semibold tracking-tight text-balance sm:text-5xl lg:text-6xl">
          {title}
        </h1>
        <p className="max-w-3xl text-base leading-8 text-muted-foreground sm:text-lg">
          {subtitle}
        </p>
        <div className="flex flex-wrap items-center gap-x-6 gap-y-3 pt-2">
          <ExternalLink link={links.linkedin} />
          <ExternalLink link={links.calendar} />
        </div>
      </section>

      <TrustedBySection {...trustedBy} />

      <section className="mt-16 border-t border-border pt-8">
        <div className="mb-5 flex items-end justify-between gap-4">
          <a
            href={featuredPostsPath}
            className="text-xl font-semibold tracking-tight text-primary underline underline-offset-8 transition-colors hover:text-primary/80 sm:text-2xl"
          >
            {featuredPostsHeading}
          </a>
        </div>

        {featuredPosts.length > 0 ? (
          <ul className="space-y-8">
            {featuredPosts.map(post => (
              <li key={post.slug}>
                <div className="flex flex-wrap items-baseline gap-x-3 gap-y-1">
                  <span className="text-muted-foreground">-</span>
                  <a
                    href={post.path}
                    className="text-lg text-primary underline underline-offset-4 transition-colors hover:text-primary/80"
                  >
                    {post.title}
                  </a>
                  <span className="text-sm text-muted-foreground">{post.published_at}</span>
                </div>
              </li>
            ))}
          </ul>
        ) : (
          <div className="py-6 text-muted-foreground">
            {featuredPostsEmpty}
          </div>
        )}
      </section>
    </div>
  );
}
