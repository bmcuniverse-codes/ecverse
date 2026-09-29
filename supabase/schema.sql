-- Run in Supabase SQL Editor. Admin access is granted through auth.users raw_app_meta_data.
create table if not exists public.site_content (
  id integer primary key default 1 check (id = 1),
  content jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);
create table if not exists public.feedback (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  rating integer not null check (rating between 1 and 5),
  liked text not null check (char_length(liked) between 1 and 1000),
  improve text not null default '' check (char_length(improve) <= 1000),
  wish text not null check (char_length(wish) between 1 and 1000)
);
create or replace function public.is_ecverse_admin() returns boolean language sql stable security invoker as $$
 select coalesce(auth.jwt()->'app_metadata'->>'role' = 'admin', false)
$$;
alter table public.site_content enable row level security;
alter table public.feedback enable row level security;
drop policy if exists "Public reads site" on public.site_content;
create policy "Public reads site" on public.site_content for select to anon, authenticated using (true);
drop policy if exists "Admin edits site" on public.site_content;
create policy "Admin edits site" on public.site_content for update to authenticated using (public.is_ecverse_admin()) with check (public.is_ecverse_admin());
drop policy if exists "Public sends feedback" on public.feedback;
create policy "Public sends feedback" on public.feedback for insert to anon, authenticated with check (true);
drop policy if exists "Admin reads feedback" on public.feedback;
create policy "Admin reads feedback" on public.feedback for select to authenticated using (public.is_ecverse_admin());
insert into public.site_content(id,content) values (1,'{}'::jsonb) on conflict (id) do nothing;
grant select on public.site_content to anon, authenticated;
grant update on public.site_content to authenticated;
grant insert on public.feedback to anon, authenticated;
grant select on public.feedback to authenticated;
