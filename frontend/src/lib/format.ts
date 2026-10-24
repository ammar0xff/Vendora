import Decimal from "decimal.js";

/** Decimal-safe money arithmetic helpers — never floats. */
export const D = (v: string | number | Decimal | null | undefined): Decimal =>
  new Decimal(v ?? 0);

const nf2 = new Intl.NumberFormat("ar-EG", { minimumFractionDigits: 2, maximumFractionDigits: 2 });
const nf3 = new Intl.NumberFormat("ar-EG", { maximumFractionDigits: 3 });

export const money = (v: string | number | Decimal | null | undefined): string =>
  nf2.format(Number(D(v).toDecimalPlaces(2).toFixed(2)));

export const moneyEGP = (v: string | number | Decimal | null | undefined): string =>
  `${money(v)} ج.م`;

export const qty = (v: string | number | Decimal | null | undefined): string =>
  nf3.format(Number(D(v).toDecimalPlaces(3).toFixed(3)));

const dtf = new Intl.DateTimeFormat("ar-EG", { dateStyle: "medium", timeStyle: "short", timeZone: "Africa/Cairo" });
const df = new Intl.DateTimeFormat("ar-EG", { dateStyle: "medium", timeZone: "Africa/Cairo" });

export const dateTime = (v: string | Date | null | undefined): string =>
  v ? dtf.format(new Date(v)) : "—";

export const date = (v: string | Date | null | undefined): string =>
  v ? df.format(new Date(v)) : "—";
