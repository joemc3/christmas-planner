-- Enable Row Level Security on all tables
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.family_budgets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.recipients ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.gifts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.meals ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.meal_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.shopping_lists ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.shopping_list_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.calendar_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.expenses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.wishlists ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.wishlist_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.budget_categories ENABLE ROW LEVEL SECURITY;

-- User Profiles Policies
CREATE POLICY "Users can view own profile" ON public.user_profiles
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON public.user_profiles
    FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile" ON public.user_profiles
    FOR INSERT WITH CHECK (auth.uid() = id);

-- Family Budgets Policies
CREATE POLICY "Users can view own budgets" ON public.family_budgets
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own budgets" ON public.family_budgets
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own budgets" ON public.family_budgets
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own budgets" ON public.family_budgets
    FOR DELETE USING (auth.uid() = user_id);

-- Recipients Policies
CREATE POLICY "Users can view own recipients" ON public.recipients
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own recipients" ON public.recipients
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own recipients" ON public.recipients
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own recipients" ON public.recipients
    FOR DELETE USING (auth.uid() = user_id);

-- Gifts Policies
CREATE POLICY "Users can view gifts for own recipients" ON public.gifts
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.recipients
            WHERE recipients.id = gifts.recipient_id
            AND recipients.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can insert gifts for own recipients" ON public.gifts
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.recipients
            WHERE recipients.id = gifts.recipient_id
            AND recipients.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can update gifts for own recipients" ON public.gifts
    FOR UPDATE USING (
        EXISTS (
            SELECT 1 FROM public.recipients
            WHERE recipients.id = gifts.recipient_id
            AND recipients.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can delete gifts for own recipients" ON public.gifts
    FOR DELETE USING (
        EXISTS (
            SELECT 1 FROM public.recipients
            WHERE recipients.id = gifts.recipient_id
            AND recipients.user_id = auth.uid()
        )
    );

-- Meals Policies
CREATE POLICY "Users can view own meals" ON public.meals
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own meals" ON public.meals
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own meals" ON public.meals
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own meals" ON public.meals
    FOR DELETE USING (auth.uid() = user_id);

-- Meal Items Policies
CREATE POLICY "Users can view meal items for own meals" ON public.meal_items
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.meals
            WHERE meals.id = meal_items.meal_id
            AND meals.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can insert meal items for own meals" ON public.meal_items
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.meals
            WHERE meals.id = meal_items.meal_id
            AND meals.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can update meal items for own meals" ON public.meal_items
    FOR UPDATE USING (
        EXISTS (
            SELECT 1 FROM public.meals
            WHERE meals.id = meal_items.meal_id
            AND meals.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can delete meal items for own meals" ON public.meal_items
    FOR DELETE USING (
        EXISTS (
            SELECT 1 FROM public.meals
            WHERE meals.id = meal_items.meal_id
            AND meals.user_id = auth.uid()
        )
    );

-- Shopping Lists Policies
CREATE POLICY "Users can view own shopping lists" ON public.shopping_lists
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own shopping lists" ON public.shopping_lists
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own shopping lists" ON public.shopping_lists
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own shopping lists" ON public.shopping_lists
    FOR DELETE USING (auth.uid() = user_id);

-- Shopping List Items Policies
CREATE POLICY "Users can view items in own shopping lists" ON public.shopping_list_items
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.shopping_lists
            WHERE shopping_lists.id = shopping_list_items.shopping_list_id
            AND shopping_lists.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can insert items in own shopping lists" ON public.shopping_list_items
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.shopping_lists
            WHERE shopping_lists.id = shopping_list_items.shopping_list_id
            AND shopping_lists.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can update items in own shopping lists" ON public.shopping_list_items
    FOR UPDATE USING (
        EXISTS (
            SELECT 1 FROM public.shopping_lists
            WHERE shopping_lists.id = shopping_list_items.shopping_list_id
            AND shopping_lists.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can delete items in own shopping lists" ON public.shopping_list_items
    FOR DELETE USING (
        EXISTS (
            SELECT 1 FROM public.shopping_lists
            WHERE shopping_lists.id = shopping_list_items.shopping_list_id
            AND shopping_lists.user_id = auth.uid()
        )
    );

-- Calendar Events Policies
CREATE POLICY "Users can view own calendar events" ON public.calendar_events
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own calendar events" ON public.calendar_events
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own calendar events" ON public.calendar_events
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own calendar events" ON public.calendar_events
    FOR DELETE USING (auth.uid() = user_id);

-- Tasks Policies
CREATE POLICY "Users can view own tasks" ON public.tasks
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own tasks" ON public.tasks
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own tasks" ON public.tasks
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own tasks" ON public.tasks
    FOR DELETE USING (auth.uid() = user_id);

-- Notifications Policies
CREATE POLICY "Users can view own notifications" ON public.notifications
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own notifications" ON public.notifications
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own notifications" ON public.notifications
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own notifications" ON public.notifications
    FOR DELETE USING (auth.uid() = user_id);

-- Expenses Policies
CREATE POLICY "Users can view own expenses" ON public.expenses
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own expenses" ON public.expenses
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own expenses" ON public.expenses
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own expenses" ON public.expenses
    FOR DELETE USING (auth.uid() = user_id);

-- Wishlists Policies
CREATE POLICY "Users can view own wishlists" ON public.wishlists
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can view public wishlists by share token" ON public.wishlists
    FOR SELECT USING (is_public = true);

CREATE POLICY "Users can insert own wishlists" ON public.wishlists
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own wishlists" ON public.wishlists
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own wishlists" ON public.wishlists
    FOR DELETE USING (auth.uid() = user_id);

-- Wishlist Items Policies
CREATE POLICY "Users can view items in own wishlists" ON public.wishlist_items
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.wishlists
            WHERE wishlists.id = wishlist_items.wishlist_id
            AND (wishlists.user_id = auth.uid() OR wishlists.is_public = true)
        )
    );

CREATE POLICY "Users can insert items in own wishlists" ON public.wishlist_items
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.wishlists
            WHERE wishlists.id = wishlist_items.wishlist_id
            AND wishlists.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can update items in own wishlists" ON public.wishlist_items
    FOR UPDATE USING (
        EXISTS (
            SELECT 1 FROM public.wishlists
            WHERE wishlists.id = wishlist_items.wishlist_id
            AND wishlists.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can claim items in public wishlists" ON public.wishlist_items
    FOR UPDATE USING (
        EXISTS (
            SELECT 1 FROM public.wishlists
            WHERE wishlists.id = wishlist_items.wishlist_id
            AND wishlists.is_public = true
        )
    );

CREATE POLICY "Users can delete items in own wishlists" ON public.wishlist_items
    FOR DELETE USING (
        EXISTS (
            SELECT 1 FROM public.wishlists
            WHERE wishlists.id = wishlist_items.wishlist_id
            AND wishlists.user_id = auth.uid()
        )
    );

-- Budget Categories Policies
CREATE POLICY "Users can view own budget categories" ON public.budget_categories
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own budget categories" ON public.budget_categories
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own budget categories" ON public.budget_categories
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own budget categories" ON public.budget_categories
    FOR DELETE USING (auth.uid() = user_id);

-- Function to create user profile on signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.user_profiles (id, email, full_name)
    VALUES (NEW.id, NEW.email, NEW.raw_user_meta_data->>'full_name');

    -- Create default shopping list
    INSERT INTO public.shopping_lists (user_id, name, is_default)
    VALUES (NEW.id, 'Main Shopping List', true);

    -- Create default budget for current year
    INSERT INTO public.family_budgets (user_id, year)
    VALUES (NEW.id, EXTRACT(YEAR FROM NOW()));

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger for new user creation
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
