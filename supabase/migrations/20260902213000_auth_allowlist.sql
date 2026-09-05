-- Only identities on this server-managed allow-list may initialize an app profile.
-- Application users never receive direct access to the allow-list itself.

create table public.authorized_emails (
  email text primary key check (email = lower(email)),
  active boolean not null default true,
  created_at timestamptz not null default now()
);

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  timezone text not null default 'Europe/Brussels',
  preferred_unit_system text not null default 'metric'
    check (preferred_unit_system in ('metric', 'imperial')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.authorized_emails enable row level security;
alter table public.profiles enable row level security;

create or replace function public.is_invited()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.authorized_emails
    where active
      and email = lower(coalesce(auth.jwt() ->> 'email', ''))
  );
$$;

revoke all on function public.is_invited() from public;
grant execute on function public.is_invited() to authenticated;

create or replace function public.activate_profile()
returns public.profiles
language plpgsql
security definer
set search_path = public
as $$
declare
  result public.profiles;
begin
  if auth.uid() is null or not public.is_invited() then
    raise exception 'access not granted' using errcode = '42501';
  end if;

  insert into public.profiles (id)
  values (auth.uid())
  on conflict (id) do update
    set updated_at = now()
  returning * into result;

  return result;
end;
$$;

revoke all on function public.activate_profile() from public;
grant execute on function public.activate_profile() to authenticated;

create policy "profiles are readable by their owner"
on public.profiles
for select
to authenticated
using (id = auth.uid());

create policy "profiles are updated by their owner"
on public.profiles
for update
to authenticated
using (id = auth.uid())
with check (id = auth.uid());
