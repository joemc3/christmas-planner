# Technical Requirements Document (TRD)

> Checked in 2026-10-14 exactly as produced in the original planning session
> (November 2025). Historical record; the current technical design is in
> `../superpowers/specs/`.

**Project Name:** Complete Christmas Planner
**Version:** 1.0
**Date:** 2025-11-15
**Frontend Stack:** Flutter (Dart)
**Backend Stack:** Supabase (Postgres)
**Deployment/Testing:** Docker

---

## 1. Technical Architecture & Stack

### 1.1. Technology Decisions

| Component | Technology | Reasoning |
| :--- | :--- | :--- |
| **Frontend/Client** | **Flutter (Dart)** | Meets the requirement for native cross-platform (iOS, Android) and web-based application delivery from a single codebase. |
| **Backend/DB/Auth** | **Supabase (Postgres)** | Provides robust, real-time Postgres database, integrated authentication, and simple scalability. Excellent official support for Flutter. |
| **Environment/Testing** | **Docker** | Required for creating reproducible development and testing environments, especially for the web build and testing against a local/staging Supabase stack. |

### 1.2. Flutter Requirements

* Must utilize **State Management** (e.g., Provider, Riverpod, BLoC) for reactive updates to budgets and totals.
* Must use the official `supabase-dart` client library for all backend interactions.

### 1.3. Supabase Requirements

* All data must leverage **Row-Level Security (RLS)** to ensure users can only access data associated with their `user_id`.
* All budget and tracking views must utilize **Supabase Realtime** for instant updates when a gift or meal item is marked 'Purchased' on any connected device.
* **Authentication:** Must implement standard email/password sign-up/sign-in using Supabase Auth.

---

## 2. Data Model (Supabase Tables)

| Table | Primary Key | Foreign Key | Key Attributes & Types | Constraints/Notes |
| :--- | :--- | :--- | :--- | :--- |
| **Users** | `id` (UUID) | - | `email`, `created_at` | Handled by Supabase Auth. |
| **Family_Budget** | `id` (UUID) | `user_id` (FK: Users) | `gift_budget_total` (Numeric), `meal_budget_eve` (Numeric), `meal_budget_day` (Numeric) | Stores top-level budget limits. |
| **Recipients** | `id` (UUID) | `user_id` (FK: Users) | `name` (Text), `budget_limit` (Numeric) | |
| **Gifts** | `id` (UUID) | `recipient_id` (FK: Recipients) | `name` (Text), `price` (Numeric), `status` (Enum: **To Buy, Ordered, Purchased**), `order_link` (Text) | |
| **Meals** | `id` (UUID) | `user_id` (FK: Users) | `type` (Enum: **Xmas_Eve, Xmas_Day**), `guest_count` (Int), `budget_limit` (Numeric) | |
| **Meal_Items** | `id` (UUID) | `meal_id` (FK: Meals) | `item_name` (Text), `cost` (Numeric), `status` (Enum: **To Buy, Purchased**) | |

---

## 3. Implementation Details

### 3.1. Calculations

* **Total Spent Fields:** The app should not store calculated totals in the database (e.g., `total_spent`). These should be calculated on the fly via **Flutter StreamBuilders/Listeners** which sum the relevant `price` or `cost` columns from related tables.
* **Timeline Calculation:** Implement the mathematical function (from PRD 3.2) in Flutter. The default `Average Shipping Days` should be stored in the **Users** table or a separate settings table to allow user configuration.

### 3.2. DevOps and Testing

* Provide a **`Dockerfile`** for building and serving the Flutter web application in a portable container.
* Provide clear instructions on connecting the Dockerized Flutter app to a **local or staging Supabase instance** for testing environment consistency.
