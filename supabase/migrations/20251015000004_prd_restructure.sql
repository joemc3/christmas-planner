-- Restructure to PRD 1.1 (docs/superpowers/specs/2026-10-14-prd-restructure-design.md,
-- section 4). Destructive by design: the only data that exists is local
-- smoke-test data and there is no hosted project yet.

-- 1. plans: the year container, replacing family_budgets.
CREATE TABLE public.plans (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    year INTEGER NOT NULL,
    gift_budget_total NUMERIC(10, 2) NOT NULL DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE (user_id, year)
);

INSERT INTO public.plans (user_id, year, gift_budget_total, created_at, updated_at)
SELECT user_id, year, gift_budget_total, created_at, updated_at
FROM public.family_budgets;

-- 2. recipients and meals hang off a plan, not a user.
ALTER TABLE public.recipients ADD COLUMN plan_id UUID REFERENCES public.plans(id) ON DELETE CASCADE;
ALTER TABLE public.meals ADD COLUMN plan_id UUID REFERENCES public.plans(id) ON DELETE CASCADE;

-- Every existing recipient joins its user's current-year plan; every meal its
-- own year's plan. Create the plans those rows need first.
INSERT INTO public.plans (user_id, year)
SELECT DISTINCT r.user_id, EXTRACT(YEAR FROM NOW())::int FROM public.recipients r
ON CONFLICT (user_id, year) DO NOTHING;

INSERT INTO public.plans (user_id, year)
SELECT DISTINCT m.user_id, m.year FROM public.meals m
ON CONFLICT (user_id, year) DO NOTHING;

UPDATE public.recipients r
SET plan_id = p.id
FROM public.plans p
WHERE p.user_id = r.user_id AND p.year = EXTRACT(YEAR FROM NOW())::int;

UPDATE public.meals m
SET plan_id = p.id
FROM public.plans p
WHERE p.user_id = m.user_id AND p.year = m.year;

-- 3. Enums reduced to the PRD values. Postgres cannot drop enum values, so
-- each type is recreated and the column retyped.
UPDATE public.gifts SET status = 'Purchased' WHERE status IN ('Wrapped', 'Delivered');
CREATE TYPE gift_status_v2 AS ENUM ('To Buy', 'Ordered', 'Purchased');
ALTER TABLE public.gifts ALTER COLUMN status DROP DEFAULT;
ALTER TABLE public.gifts ALTER COLUMN status TYPE gift_status_v2 USING status::text::gift_status_v2;
DROP TYPE gift_status;
ALTER TYPE gift_status_v2 RENAME TO gift_status;
ALTER TABLE public.gifts ALTER COLUMN status SET DEFAULT 'To Buy';

DELETE FROM public.meals WHERE type = 'Other';
CREATE TYPE meal_type_v2 AS ENUM ('Xmas_Eve', 'Xmas_Day');
ALTER TABLE public.meals ALTER COLUMN type TYPE meal_type_v2 USING type::text::meal_type_v2;
DROP TYPE meal_type;
ALTER TYPE meal_type_v2 RENAME TO meal_type;

UPDATE public.meal_items SET status = 'Purchased' WHERE status = 'Prepared';
CREATE TYPE meal_item_status_v2 AS ENUM ('To Buy', 'Purchased');
ALTER TABLE public.meal_items ALTER COLUMN status DROP DEFAULT;
ALTER TABLE public.meal_items ALTER COLUMN status TYPE meal_item_status_v2 USING status::text::meal_item_status_v2;
DROP TYPE meal_item_status;
ALTER TYPE meal_item_status_v2 RENAME TO meal_item_status;
ALTER TABLE public.meal_items ALTER COLUMN status SET DEFAULT 'To Buy';

-- RLS for recipients, gifts, meals and meal_items is rewritten before the
-- user_id columns go, because the old policies depend on them.
DROP POLICY "Users can view own recipients" ON public.recipients;
DROP POLICY "Users can insert own recipients" ON public.recipients;
DROP POLICY "Users can update own recipients" ON public.recipients;
DROP POLICY "Users can delete own recipients" ON public.recipients;

CREATE POLICY "Users can view recipients in own plans" ON public.recipients
    FOR SELECT USING (EXISTS (
        SELECT 1 FROM public.plans p WHERE p.id = recipients.plan_id AND p.user_id = auth.uid()));
CREATE POLICY "Users can insert recipients in own plans" ON public.recipients
    FOR INSERT WITH CHECK (EXISTS (
        SELECT 1 FROM public.plans p WHERE p.id = recipients.plan_id AND p.user_id = auth.uid()));
CREATE POLICY "Users can update recipients in own plans" ON public.recipients
    FOR UPDATE USING (EXISTS (
        SELECT 1 FROM public.plans p WHERE p.id = recipients.plan_id AND p.user_id = auth.uid()));
CREATE POLICY "Users can delete recipients in own plans" ON public.recipients
    FOR DELETE USING (EXISTS (
        SELECT 1 FROM public.plans p WHERE p.id = recipients.plan_id AND p.user_id = auth.uid()));

DROP POLICY "Users can view gifts for own recipients" ON public.gifts;
DROP POLICY "Users can insert gifts for own recipients" ON public.gifts;
DROP POLICY "Users can update gifts for own recipients" ON public.gifts;
DROP POLICY "Users can delete gifts for own recipients" ON public.gifts;

CREATE POLICY "Users can view gifts in own plans" ON public.gifts
    FOR SELECT USING (EXISTS (
        SELECT 1 FROM public.recipients r JOIN public.plans p ON p.id = r.plan_id
        WHERE r.id = gifts.recipient_id AND p.user_id = auth.uid()));
CREATE POLICY "Users can insert gifts in own plans" ON public.gifts
    FOR INSERT WITH CHECK (EXISTS (
        SELECT 1 FROM public.recipients r JOIN public.plans p ON p.id = r.plan_id
        WHERE r.id = gifts.recipient_id AND p.user_id = auth.uid()));
CREATE POLICY "Users can update gifts in own plans" ON public.gifts
    FOR UPDATE USING (EXISTS (
        SELECT 1 FROM public.recipients r JOIN public.plans p ON p.id = r.plan_id
        WHERE r.id = gifts.recipient_id AND p.user_id = auth.uid()));
CREATE POLICY "Users can delete gifts in own plans" ON public.gifts
    FOR DELETE USING (EXISTS (
        SELECT 1 FROM public.recipients r JOIN public.plans p ON p.id = r.plan_id
        WHERE r.id = gifts.recipient_id AND p.user_id = auth.uid()));

DROP POLICY "Users can view own meals" ON public.meals;
DROP POLICY "Users can insert own meals" ON public.meals;
DROP POLICY "Users can update own meals" ON public.meals;
DROP POLICY "Users can delete own meals" ON public.meals;

CREATE POLICY "Users can view meals in own plans" ON public.meals
    FOR SELECT USING (EXISTS (
        SELECT 1 FROM public.plans p WHERE p.id = meals.plan_id AND p.user_id = auth.uid()));
CREATE POLICY "Users can insert meals in own plans" ON public.meals
    FOR INSERT WITH CHECK (EXISTS (
        SELECT 1 FROM public.plans p WHERE p.id = meals.plan_id AND p.user_id = auth.uid()));
CREATE POLICY "Users can update meals in own plans" ON public.meals
    FOR UPDATE USING (EXISTS (
        SELECT 1 FROM public.plans p WHERE p.id = meals.plan_id AND p.user_id = auth.uid()));
CREATE POLICY "Users can delete meals in own plans" ON public.meals
    FOR DELETE USING (EXISTS (
        SELECT 1 FROM public.plans p WHERE p.id = meals.plan_id AND p.user_id = auth.uid()));

DROP POLICY "Users can view meal items for own meals" ON public.meal_items;
DROP POLICY "Users can insert meal items for own meals" ON public.meal_items;
DROP POLICY "Users can update meal items for own meals" ON public.meal_items;
DROP POLICY "Users can delete meal items for own meals" ON public.meal_items;

CREATE POLICY "Users can view meal items in own plans" ON public.meal_items
    FOR SELECT USING (EXISTS (
        SELECT 1 FROM public.meals m JOIN public.plans p ON p.id = m.plan_id
        WHERE m.id = meal_items.meal_id AND p.user_id = auth.uid()));
CREATE POLICY "Users can insert meal items in own plans" ON public.meal_items
    FOR INSERT WITH CHECK (EXISTS (
        SELECT 1 FROM public.meals m JOIN public.plans p ON p.id = m.plan_id
        WHERE m.id = meal_items.meal_id AND p.user_id = auth.uid()));
CREATE POLICY "Users can update meal items in own plans" ON public.meal_items
    FOR UPDATE USING (EXISTS (
        SELECT 1 FROM public.meals m JOIN public.plans p ON p.id = m.plan_id
        WHERE m.id = meal_items.meal_id AND p.user_id = auth.uid()));
CREATE POLICY "Users can delete meal items in own plans" ON public.meal_items
    FOR DELETE USING (EXISTS (
        SELECT 1 FROM public.meals m JOIN public.plans p ON p.id = m.plan_id
        WHERE m.id = meal_items.meal_id AND p.user_id = auth.uid()));

-- 4. Columns: add purchased_date, drop everything the PRD does not name.
ALTER TABLE public.gifts ADD COLUMN purchased_date DATE;
UPDATE public.gifts SET purchased_date = COALESCE(actual_delivery_date, wrapped_date, order_date)
WHERE status = 'Purchased';

ALTER TABLE public.user_profiles
    DROP COLUMN avatar_url,
    DROP COLUMN timezone,
    DROP COLUMN notification_preferences;

ALTER TABLE public.recipients
    DROP COLUMN user_id,
    DROP COLUMN relationship,
    DROP COLUMN age_group,
    DROP COLUMN interests,
    DROP COLUMN notes,
    DROP COLUMN avatar_url,
    DROP COLUMN priority,
    DROP COLUMN archived,
    ALTER COLUMN plan_id SET NOT NULL;

ALTER TABLE public.gifts
    DROP COLUMN description,
    DROP COLUMN actual_price,
    DROP COLUMN tracking_number,
    DROP COLUMN expected_delivery_date,
    DROP COLUMN actual_delivery_date,
    DROP COLUMN wrapped_date,
    DROP COLUMN category,
    DROP COLUMN image_url,
    DROP COLUMN priority,
    DROP COLUMN notes,
    DROP COLUMN is_surprise;

ALTER TABLE public.meals
    DROP COLUMN user_id,
    DROP COLUMN year,
    DROP COLUMN name,
    DROP COLUMN meal_time,
    DROP COLUMN location,
    DROP COLUMN theme,
    DROP COLUMN dietary_restrictions,
    DROP COLUMN notes,
    ALTER COLUMN plan_id SET NOT NULL;

ALTER TABLE public.meal_items
    DROP COLUMN description,
    DROP COLUMN quantity,
    DROP COLUMN actual_cost,
    DROP COLUMN store_name,
    DROP COLUMN category,
    DROP COLUMN recipe_link,
    DROP COLUMN prep_time,
    DROP COLUMN cook_time,
    DROP COLUMN assigned_to,
    DROP COLUMN notes;

-- 8 (early, so the ensure_plan function below can rely on it): one meal of
-- each type per plan.
ALTER TABLE public.meals ADD CONSTRAINT meals_plan_type_unique UNIQUE (plan_id, type);

CREATE INDEX idx_recipients_plan_id ON public.recipients(plan_id);
CREATE INDEX idx_meals_plan_id ON public.meals(plan_id);
CREATE INDEX idx_plans_user_id ON public.plans(user_id);

-- 5. Removed tables (their policies, triggers, indexes and publication
-- membership go with them), then family_budgets.
DROP TABLE IF EXISTS public.shopping_list_items;
DROP TABLE IF EXISTS public.shopping_lists;
DROP TABLE IF EXISTS public.calendar_events;
DROP TABLE IF EXISTS public.tasks;
DROP TABLE IF EXISTS public.notifications;
DROP TABLE IF EXISTS public.expenses;
DROP TABLE IF EXISTS public.wishlist_items;
DROP TABLE IF EXISTS public.wishlists;
DROP TABLE IF EXISTS public.budget_categories;
DROP TABLE public.family_budgets;

-- RLS: plans by user; recipients and meals through their plan; gifts and
-- meal_items through their parent's plan.
ALTER TABLE public.plans ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own plans" ON public.plans
    FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own plans" ON public.plans
    FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own plans" ON public.plans
    FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own plans" ON public.plans
    FOR DELETE USING (auth.uid() = user_id);

-- Realtime: plans joins the publication; dropped tables left it with DROP.
CREATE TRIGGER update_plans_updated_at BEFORE UPDATE ON public.plans
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
ALTER PUBLICATION supabase_realtime ADD TABLE public.plans;
ALTER TABLE public.plans REPLICA IDENTITY FULL;

-- 6. A new account gets a profile and nothing else; the plan is created on
-- first open by ensure_plan.
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    INSERT INTO public.user_profiles (id, email, full_name)
    VALUES (NEW.id, NEW.email, NEW.raw_user_meta_data->>'full_name');
    RETURN NEW;
END;
$$;

-- 7. ensure_plan(year): the caller's plan for that year with its two meals,
-- created if missing. Idempotent; called when Home opens.
CREATE OR REPLACE FUNCTION public.ensure_plan(p_year INTEGER)
RETURNS public.plans
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_uid UUID := auth.uid();
    v_plan public.plans;
BEGIN
    IF v_uid IS NULL THEN
        RAISE EXCEPTION 'not authenticated' USING ERRCODE = '28000';
    END IF;

    INSERT INTO public.plans (user_id, year)
    VALUES (v_uid, p_year)
    ON CONFLICT (user_id, year) DO NOTHING;

    SELECT * INTO v_plan FROM public.plans WHERE user_id = v_uid AND year = p_year;

    INSERT INTO public.meals (plan_id, type)
    VALUES (v_plan.id, 'Xmas_Eve'), (v_plan.id, 'Xmas_Day')
    ON CONFLICT (plan_id, type) DO NOTHING;

    RETURN v_plan;
END;
$$;

REVOKE ALL ON FUNCTION public.ensure_plan(INTEGER) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.ensure_plan(INTEGER) TO authenticated;
