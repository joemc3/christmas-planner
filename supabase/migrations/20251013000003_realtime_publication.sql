-- The app subscribes to live changes with supabase_flutter's .stream(), which
-- uses Postgres Changes. Tables must be in the supabase_realtime publication
-- for that to deliver anything; without this every list only loads once.
-- RLS still applies: Realtime only forwards rows the subscriber may select.
ALTER PUBLICATION supabase_realtime ADD TABLE
    public.user_profiles,
    public.family_budgets,
    public.recipients,
    public.gifts,
    public.meals,
    public.meal_items,
    public.shopping_lists,
    public.shopping_list_items,
    public.calendar_events,
    public.tasks,
    public.notifications,
    public.expenses;

-- Realtime needs full row images to apply filters on UPDATE/DELETE.
ALTER TABLE public.recipients REPLICA IDENTITY FULL;
ALTER TABLE public.gifts REPLICA IDENTITY FULL;
ALTER TABLE public.meals REPLICA IDENTITY FULL;
ALTER TABLE public.meal_items REPLICA IDENTITY FULL;
ALTER TABLE public.shopping_lists REPLICA IDENTITY FULL;
ALTER TABLE public.shopping_list_items REPLICA IDENTITY FULL;
ALTER TABLE public.calendar_events REPLICA IDENTITY FULL;
ALTER TABLE public.family_budgets REPLICA IDENTITY FULL;
