import { useState } from "react";
import { Link, Outlet, useLocation, useNavigate } from "react-router-dom";
import { useQuery } from "@tanstack/react-query";
import { Building2, Clock, Droplets, LogOut, Menu, Moon, Sun, UserRound } from "lucide-react";
import { api } from "@/lib/api";
import { NAV_GROUPS, NAV_ITEMS, type NavItem } from "@/lib/nav";
import { cn } from "@/lib/utils";
import { useAuth } from "@/stores/auth";
import { Avatar, AvatarFallback } from "@/components/kit/avatar";
import { Badge } from "@/components/kit/badge";
import { Button } from "@/components/kit/button";
import {
  DropdownMenu, DropdownMenuContent, DropdownMenuGroup, DropdownMenuItem,
  DropdownMenuLabel, DropdownMenuRadioGroup, DropdownMenuRadioItem, DropdownMenuTrigger,
} from "@/components/kit/dropdown-menu";
import { Sheet, SheetContent, SheetTitle } from "@/components/kit/sheet";
import { PageTransition } from "@/components/motion";
import { dateTime } from "@/lib/format";

interface Warehouse {
  id: string;
  name: string;
  kind?: string;
}

export function useBranch() {
  const user = useAuth((s) => s.user);
  const { data } = useQuery({
    queryKey: ["warehouses"],
    queryFn: () => api.get<Warehouse[]>("/stock/warehouses"),
    staleTime: 5 * 60_000,
  });
  const [branchId, setBranchId] = useState<string | null>(() => localStorage.getItem("vendora.branch"));
  const current = data?.find((w) => w.id === branchId) ?? data?.find((w) => w.id === user?.default_warehouse_id) ?? data?.[0];
  return { warehouses: data ?? [], branchId: current?.id ?? null, branchName: current?.name ?? "…", setBranchId };
}

function AppSidebar({ onNavigate }: { onNavigate?: () => void }) {
  const pathname = useLocation().pathname;
  const { can } = useAuth();
  const visible = NAV_ITEMS.filter((n) => !n.perm || can(n.perm));
  const groups = (Object.keys(NAV_GROUPS) as NavItem["group"][])
    .map((g) => ({ id: g, label: NAV_GROUPS[g], items: visible.filter((n) => n.group === g) }))
    .filter((g) => g.items.length > 0);

  return (
    <div className="flex h-full flex-col bg-sidebar text-sidebar-foreground">
      <div className="flex h-16 items-center gap-3 border-b border-sidebar-border px-5">
        <span className="flex size-9 items-center justify-center rounded-lg bg-sidebar-primary text-sidebar-primary-foreground">
          <Droplets className="size-5" aria-hidden />
        </span>
        <div className="flex flex-col leading-tight">
          <span className="font-semibold">فيندورا</span>
          <span className="text-xs text-sidebar-foreground/60">المصرية الألمانية</span>
        </div>
      </div>
      <nav aria-label="القائمة الرئيسية" className="flex-1 overflow-y-auto px-3 py-4">
        <div className="flex flex-col gap-5">
          {groups.map((group) => (
            <div key={group.id} className="flex flex-col gap-1">
              <p className="px-3 pb-1 text-[11px] font-medium text-sidebar-foreground/50">{group.label}</p>
              {group.items.map((item) => {
                const active = item.to === "/" ? pathname === "/" : pathname === item.to || pathname.startsWith(`${item.to}/`);
                const Icon = item.icon;
                return (
                  <Link
                    key={item.to}
                    to={item.to}
                    onClick={onNavigate}
                    aria-current={active ? "page" : undefined}
                    className={cn(
                      "flex items-center gap-3 rounded-md px-3 py-2 text-sm text-sidebar-foreground/80 transition-colors hover:bg-sidebar-accent hover:text-sidebar-accent-foreground focus-visible:outline-2 focus-visible:outline-sidebar-ring",
                      active && "bg-sidebar-accent font-medium text-sidebar-accent-foreground",
                    )}
                  >
                    <Icon className={cn("size-4 shrink-0", active && "text-sidebar-primary")} aria-hidden />
                    <span className="truncate">{item.label}</span>
                  </Link>
                );
              })}
            </div>
          ))}
        </div>
      </nav>
      <div className="border-t border-sidebar-border px-5 py-3 text-[11px] text-sidebar-foreground/50">
        الإصدار <span className="num">2.4.0</span>
      </div>
    </div>
  );
}

function AppTopbar({ onOpenMenu }: { onOpenMenu: () => void }) {
  const navigate = useNavigate();
  const { user, logout } = useAuth();
  const { warehouses, branchId, branchName, setBranchId } = useBranch();

  const shift = useQuery({
    queryKey: ["shift", "topbar", branchId],
    queryFn: () => api.get<{ id: string; started_at: string }>("/shifts/current", { warehouse_id: branchId! }),
    enabled: !!branchId,
    retry: false,
    refetchInterval: 60_000,
  });

  function toggleTheme() {
    const dark = document.documentElement.classList.toggle("dark");
    localStorage.setItem("vendora.theme", dark ? "dark" : "light");
  }

  return (
    <header className="no-print sticky top-0 z-30 flex h-16 items-center gap-2 border-b bg-background/90 px-4 backdrop-blur supports-[backdrop-filter]:bg-background/75 md:px-6">
      <Button variant="ghost" size="icon" className="lg:hidden" onClick={onOpenMenu} aria-label="فتح القائمة">
        <Menu />
      </Button>

      <DropdownMenu>
        <DropdownMenuTrigger render={<Button variant="outline" size="sm" />}>
          <Building2 data-icon="inline-start" />
          <span className="max-w-32 truncate">{branchName}</span>
        </DropdownMenuTrigger>
        <DropdownMenuContent align="start" className="w-52">
          <DropdownMenuGroup>
            <DropdownMenuLabel>الفرع الحالي</DropdownMenuLabel>
            <DropdownMenuRadioGroup
              value={branchId ?? ""}
              onValueChange={(v) => {
                localStorage.setItem("vendora.branch", String(v));
                setBranchId(String(v));
              }}
            >
              {warehouses.map((b) => (
                <DropdownMenuRadioItem key={b.id} value={b.id}>
                  {b.name}
                </DropdownMenuRadioItem>
              ))}
            </DropdownMenuRadioGroup>
          </DropdownMenuGroup>
        </DropdownMenuContent>
      </DropdownMenu>

      <Link to="/shifts" className="hidden sm:block">
        {shift.data ? (
          <Badge variant="success" className="h-7 gap-1.5 px-2.5">
            <span className="size-1.5 rounded-full bg-success" aria-hidden />
            وردية مفتوحة · <span className="num">{dateTime(shift.data.started_at)}</span>
          </Badge>
        ) : (
          <Badge variant="secondary" className="h-7 gap-1.5 px-2.5">
            <Clock className="size-3" aria-hidden />
            لا توجد وردية
          </Badge>
        )}
      </Link>

      <div className="ms-auto flex items-center gap-1">
        <Button variant="ghost" size="icon" aria-label="تبديل الوضع الليلي" onClick={toggleTheme}>
          <Sun className="dark:hidden" />
          <Moon className="hidden dark:block" />
        </Button>

        <DropdownMenu>
          <DropdownMenuTrigger render={<Button variant="ghost" className="h-10 gap-2 px-2" />} aria-label="قائمة المستخدم">
            <Avatar className="size-8">
              <AvatarFallback>{(user?.full_name ?? "؟").split(" ")[0].slice(0, 2)}</AvatarFallback>
            </Avatar>
            <span className="hidden flex-col items-start leading-tight md:flex">
              <span className="text-sm font-medium">{user?.full_name}</span>
              <span className="text-xs text-muted-foreground">{user?.role}</span>
            </span>
          </DropdownMenuTrigger>
          <DropdownMenuContent align="end" className="w-56">
            <DropdownMenuGroup>
              <DropdownMenuItem onClick={() => navigate("/settings")}>
                <UserRound />
                الإعدادات
              </DropdownMenuItem>
              <DropdownMenuItem
                variant="destructive"
                onClick={() => {
                  logout();
                  navigate("/login", { replace: true });
                }}
              >
                <LogOut />
                تسجيل الخروج
              </DropdownMenuItem>
            </DropdownMenuGroup>
          </DropdownMenuContent>
        </DropdownMenu>
      </div>
    </header>
  );
}

export default function Shell() {
  const [menuOpen, setMenuOpen] = useState(false);
  const pathname = useLocation().pathname;

  return (
    <div className="flex min-h-svh">
      <aside className="no-print sticky top-0 hidden h-svh w-64 shrink-0 lg:block">
        <AppSidebar />
      </aside>
      <Sheet open={menuOpen} onOpenChange={setMenuOpen}>
        <SheetContent side="right" className="w-72 p-0" showCloseButton={false}>
          <SheetTitle className="sr-only">القائمة الرئيسية</SheetTitle>
          <AppSidebar onNavigate={() => setMenuOpen(false)} />
        </SheetContent>
      </Sheet>
      <div className="flex min-w-0 flex-1 flex-col">
        <AppTopbar onOpenMenu={() => setMenuOpen(true)} />
        <main className="flex-1 px-4 py-6 md:px-6 lg:px-8">
          <PageTransition routeKey={pathname}>
            <Outlet />
          </PageTransition>
        </main>
      </div>
    </div>
  );
}
