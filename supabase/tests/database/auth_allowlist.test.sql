begin;

create extension if not exists pgtap;
select plan(6);

select has_table('public', 'authorized_emails', 'allow-list table exists');
select has_table('public', 'profiles', 'profile table exists');
select ok(
  (
    select c.relrowsecurity
    from pg_class c
    join pg_namespace n on n.oid = c.relnamespace
    where n.nspname = 'public' and c.relname = 'authorized_emails'
  ),
  'allow-list uses RLS'
);
select ok(
  (
    select c.relrowsecurity
    from pg_class c
    join pg_namespace n on n.oid = c.relnamespace
    where n.nspname = 'public' and c.relname = 'profiles'
  ),
  'profiles use RLS'
);
select has_function('public', 'is_invited', 'invite check is exposed as a function');
select has_function('public', 'activate_profile', 'profile activation is gated');

select * from finish();
rollback;
