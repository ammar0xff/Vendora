import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { Eye, EyeOff, LogIn } from "lucide-react";
import { api } from "@/lib/api";
import { Button, ErrorBox, Input, Spinner } from "@/components/ui";
import { useAuth, type User } from "@/stores/auth";

interface LoginResponse {
  access_token: string;
  user_id: string;
  username: string;
  full_name: string;
  role: User["role"];
}

export default function LoginPage() {
  const [username, setUsername] = useState("");
  const [password, setPassword] = useState("");
  const [show, setShow] = useState(false);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const navigate = useNavigate();
  const login = useAuth((s) => s.login);

  async function submit(e: React.FormEvent) {
    e.preventDefault();
    setBusy(true);
    setError(null);
    try {
      const r = await api.post<LoginResponse>("/auth/login", { username, password });
      const me = await api.get<User>("/auth/me");
      login(r.access_token, me);
      navigate("/", { replace: true });
    } catch (err) {
      setError(err instanceof Error ? err.message : "تعذر تسجيل الدخول");
    } finally {
      setBusy(false);
    }
  }

  return (
    <div className="grid min-h-screen place-items-center bg-bg p-4">
      <div className="w-full max-w-sm rounded-2xl border border-line bg-surface p-8 shadow-xl">
        <div className="mb-8 text-center">
          <div className="mx-auto mb-3 grid h-14 w-14 place-items-center rounded-2xl bg-brand text-2xl font-black text-brand-ink">
            ف
          </div>
          <h1 className="text-xl font-bold">فيندورا</h1>
          <p className="mt-1 text-sm text-muted">نظام إدارة المتاجر والمخازن</p>
        </div>
        <form onSubmit={submit} className="space-y-4">
          <div>
            <label htmlFor="u" className="mb-1 block text-sm font-medium">اسم المستخدم</label>
            <Input id="u" value={username} onChange={(e) => setUsername(e.target.value)} autoComplete="username" required autoFocus />
          </div>
          <div>
            <label htmlFor="p" className="mb-1 block text-sm font-medium">كلمة المرور</label>
            <div className="relative">
              <Input
                id="p"
                type={show ? "text" : "password"}
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                autoComplete="current-password"
                required
                className="pl-10"
              />
              <button
                type="button"
                onClick={() => setShow((s) => !s)}
                className="absolute left-2 top-1/2 -translate-y-1/2 rounded p-1 text-muted hover:text-ink"
                aria-label={show ? "إخفاء كلمة المرور" : "إظهار كلمة المرور"}
              >
                {show ? <EyeOff size={16} /> : <Eye size={16} />}
              </button>
            </div>
          </div>
          {error && <ErrorBox message={error} />}
          <Button type="submit" disabled={busy || !username || !password} className="w-full">
            {busy ? <Spinner /> : <LogIn size={16} />}
            تسجيل الدخول
          </Button>
        </form>
      </div>
    </div>
  );
}
