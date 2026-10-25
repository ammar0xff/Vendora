import { describe, expect, it } from "vitest";
import { D, money, moneyEGP, qty } from "@/lib/format";

describe("decimal-safe money math", () => {
  it("adds without float drift", () => {
    // classic float trap: 0.1 + 0.2 !== 0.3
    expect(D("0.1").plus(D("0.2")).toString()).toBe("0.3");
    expect(D("48.00").plus(D("48.00")).toString()).toBe("96");
  });

  it("computes line totals exactly", () => {
    const line = D("33.10").times(3).minus(D("1.15"));
    expect(line.toString()).toBe("98.15");
  });

  it("handles null/undefined as zero", () => {
    expect(D(null).toString()).toBe("0");
    expect(D(undefined).plus(D("5")).toString()).toBe("5");
  });

  it("formats money with 2 decimals and Arabic locale", () => {
    expect(money("1234.5")).toBe("1,234.50");
    expect(moneyEGP("48")).toContain("48.00");
  });

  it("formats quantities with up to 3 decimals", () => {
    expect(qty("2.5")).toMatch(/2\.5/);
  });
});
