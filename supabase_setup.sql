-- Run once in Supabase SQL Editor for the Tree Survey Mapper.
-- Team access assumes invited users sign in with Supabase Auth.

create table if not exists public.corrections (
  survey text not null,
  tree_id text not null,
  c_lat double precision,
  c_lng double precision,
  note text,
  updated_by text,
  updated_at timestamptz not null default now(),
  primary key (survey, tree_id)
);

alter table public.corrections enable row level security;
drop policy if exists "team read" on public.corrections;
drop policy if exists "team insert" on public.corrections;
drop policy if exists "team update" on public.corrections;
create policy "team read" on public.corrections for select to authenticated using (true);
create policy "team insert" on public.corrections for insert to authenticated with check (true);
create policy "team update" on public.corrections for update to authenticated using (true) with check (true);

create table if not exists public.survey_data (
  survey text primary key,
  payload jsonb not null,
  updated_by text,
  updated_at timestamptz not null default now()
);
alter table public.survey_data enable row level security;
drop policy if exists "team read survey data" on public.survey_data;
drop policy if exists "team insert survey data" on public.survey_data;
drop policy if exists "team update survey data" on public.survey_data;
create policy "team read survey data" on public.survey_data for select to authenticated using (true);
create policy "team insert survey data" on public.survey_data for insert to authenticated with check (true);
create policy "team update survey data" on public.survey_data for update to authenticated using (true) with check (true);

create table if not exists public.survey_photos (
  id uuid primary key default gen_random_uuid(),
  survey text not null,
  tree_id text not null,
  storage_path text not null unique,
  file_name text not null,
  photo_time bigint,
  created_by text,
  created_at timestamptz not null default now()
);
create index if not exists survey_photos_survey_tree_idx on public.survey_photos (survey, tree_id);
alter table public.survey_photos enable row level security;
drop policy if exists "team read photos" on public.survey_photos;
drop policy if exists "team insert photos" on public.survey_photos;
drop policy if exists "team delete photos" on public.survey_photos;
create policy "team read photos" on public.survey_photos for select to authenticated using (true);
create policy "team insert photos" on public.survey_photos for insert to authenticated with check (true);
create policy "team delete photos" on public.survey_photos for delete to authenticated using (true);

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('survey-photos', 'survey-photos', false, 10485760, array['image/jpeg','image/png','image/webp'])
on conflict (id) do update set public = false, file_size_limit = 10485760,
  allowed_mime_types = array['image/jpeg','image/png','image/webp'];

drop policy if exists "team upload survey photos" on storage.objects;
drop policy if exists "team read survey photos" on storage.objects;
drop policy if exists "team delete survey photos" on storage.objects;
create policy "team upload survey photos" on storage.objects for insert to authenticated
  with check (bucket_id = 'survey-photos');
create policy "team read survey photos" on storage.objects for select to authenticated
  using (bucket_id = 'survey-photos');
create policy "team delete survey photos" on storage.objects for delete to authenticated
  using (bucket_id = 'survey-photos');

do $$ begin
  alter publication supabase_realtime add table public.corrections;
exception when duplicate_object then null;
end $$;
do $$ begin
  alter publication supabase_realtime add table public.survey_data;
exception when duplicate_object then null;
end $$;
do $$ begin
  alter publication supabase_realtime add table public.survey_photos;
exception when duplicate_object then null;
end $$;
