/**
 * Shared motion primitives — physical, purposeful, reduced-motion aware.
 * Springs (not durations) so interactions feel like Framer-quality physics.
 */
import { AnimatePresence, motion, useReducedMotion } from "motion/react";
import { useEffect, useRef, useState, type ReactNode } from "react";
import { D } from "@/lib/format";

export const spring = { type: "spring", stiffness: 400, damping: 34 } as const;
export const softSpring = { type: "spring", stiffness: 260, damping: 28 } as const;

/** Route-level page transition: gentle rise + fade, keyed by pathname. */
export function PageTransition({ routeKey, children }: { routeKey: string; children: ReactNode }) {
  const reduce = useReducedMotion();
  return (
    <AnimatePresence mode="wait" initial={false}>
      <motion.div
        key={routeKey}
        initial={reduce ? false : { opacity: 0, y: 8 }}
        animate={{ opacity: 1, y: 0 }}
        exit={reduce ? undefined : { opacity: 0, y: -6 }}
        transition={reduce ? { duration: 0 } : { duration: 0.18, ease: "easeOut" }}
      >
        {children}
      </motion.div>
    </AnimatePresence>
  );
}

/** Staggered container — children reveal in sequence. */
export function Stagger({ children, className, delay = 0 }: { children: ReactNode; className?: string; delay?: number }) {
  const reduce = useReducedMotion();
  return (
    <motion.div
      className={className}
      initial={reduce ? undefined : "hidden"}
      animate="show"
      variants={{ hidden: {}, show: { transition: { staggerChildren: 0.04, delayChildren: delay } } }}
    >
      {children}
    </motion.div>
  );
}

export function StaggerItem({ children, className }: { children: ReactNode; className?: string }) {
  const reduce = useReducedMotion();
  return (
    <motion.div
      className={className}
      variants={
        reduce
          ? undefined
          : { hidden: { opacity: 0, y: 10 }, show: { opacity: 1, y: 0, transition: softSpring } }
      }
    >
      {children}
    </motion.div>
  );
}

/** Animated number — springs from previous value to the next. Money-safe via Decimal. */
export function CountUp({ value, format }: { value: string | number; format: (v: string) => string }) {
  const target = Number(D(value).toDecimalPlaces(2).toFixed(2));
  const [display, setDisplay] = useState(0);
  const reduce = useReducedMotion();
  const prev = useRef(0);

  useEffect(() => {
    if (reduce) {
      setDisplay(target);
      prev.current = target;
      return;
    }
    const controls = { stop: () => {}, stopped: false };
    const from = prev.current;
    const start = performance.now();
    const dur = 500;
    let raf = 0;
    const tick = (now: number) => {
      if (controls.stopped) return;
      const t = Math.min(1, (now - start) / dur);
      // easeOutCubic
      const eased = 1 - Math.pow(1 - t, 3);
      setDisplay(from + (target - from) * eased);
      if (t < 1) raf = requestAnimationFrame(tick);
      else prev.current = target;
    };
    raf = requestAnimationFrame(tick);
    return () => { controls.stopped = true; cancelAnimationFrame(raf); };
  }, [target, reduce]);

  return <span className="num">{format(String(Math.round(display * 100) / 100))}</span>;
}
