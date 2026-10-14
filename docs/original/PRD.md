# Product Requirements Document (PRD)

> Checked in 2026-10-14 exactly as produced in the original planning session
> (a different agent and product, November 2025). This is the historical
> record. The current product definition is `../PRD.md`.
>
> The idea it was written from, verbatim: "create an app where you can list
> all of the family members that you need to buy Christmas gift gifts for the
> budget for each family member the total number of gifts you get for each
> family member the total cost of each person and the family and keep track of
> the total budget also, it needs to be able to give an approximate date prior
> to December 25 when you need to start ordering to stay within your budget."

**Project Name:** Complete Christmas Planner
**Version:** 1.0
**Date:** 2025-11-15
**Goal:** Develop a seamless, cross-platform mobile and web application for comprehensive Christmas gift and meal planning, budgeting, and timeline management.

---

## 1. Target Audience

Individuals and families seeking an organized way to manage complex Christmas logistics, budgets, and timelines across both gift-giving and holiday meal preparation.

---

## 2. Core Feature Requirements

### 2.1. Gift Planning & Budgeting

| Feature ID | Requirement | Description |
| :--- | :--- | :--- |
| **GIFT-001** | **Recipient Management** | User must be able to **Add, Edit, and Delete** individual gift recipients (family members). |
| **GIFT-002** | **Individual Budget** | User must assign a maximum **Individual Budget** to each recipient. |
| **GIFT-003** | **Gift Tracking** | For each recipient, user must list individual gifts, including: **Item Name, Price, Store/Link, and Status** (To Buy, Ordered, Purchased). |
| **GIFT-004** | **Master Gift Budget** | Display a dashboard view showing: **Total Gift Budget**, **Total Spent**, and **Remaining Budget**. |
| **GIFT-005** | **Gift Count** | Track and display the **Total Number of Gifts** planned vs. purchased for each recipient. |
| **GIFT-006** | **Ordering Timeline** | Automatically calculate and display a suggested **"Start Ordering By" Date** based on a fixed preparation target. |

### 2.2. Meal Planning & Budgeting

| Feature ID | Requirement | Description |
| :--- | :--- | :--- |
| **MEAL-001** | **Meal Type Setup** | Allow setup for two distinct meals: **Christmas Eve Dinner** and **Christmas Day Meal**. |
| **MEAL-002** | **Guest Count** | Input the **Total Number of People** attending each meal. |
| **MEAL-003** | **Meal Budget** | Assign a separate, maximum **Budget** for the Christmas Eve meal and the Christmas Day meal. |
| **MEAL-004** | **Menu Item Tracking** | For each meal, list required **Menu Items/Ingredients**, including **Cost** and **Purchase Status** (To Buy, Purchased). |
| **MEAL-005** | **Master Meal Budget** | Display a view showing **Total Meal Budget**, **Total Meal Spent**, and **Remaining Meal Budget**. |

---

## 3. Key Business Logic

### 3.1. Target Preparation Date

The ultimate goal for all ordering and necessary preparation (wrapping, shipping, planning) is **December 10th**.

### 3.2. Timeline Calculation Logic (GIFT-006)

The app must calculate the "Start Ordering By" date based on the following:

$$\text{Start Date} = \text{December 10th} - (\text{Default Buffer Days} + \text{Average Shipping Days})$$

* **Fixed Target Date:** December 10th
* **Default Buffer Days (B):** 7 days (Time needed for wrapping, final prep, and contingency).
* **Average Shipping Days (S):** Default 7 days (Must be user-configurable in settings).

**Default Calculation Example:** December 10th - (7 + 7) days = **November 26th**.

### 3.3. Budget Calculation Logic

* **Total Gift Spent:** Sum of all `Gifts.price` where `Status` is 'Ordered' or 'Purchased'.
* **Remaining Gift Budget:** `Family_Budget.gift_budget_total` - `Total Gift Spent`.
* **Total Meal Spent:** Sum of all `Meal_Items.cost` where `Status` is 'Purchased'.
* **Remaining Meal Budget:** `Meals.budget_limit` - `Total Meal Spent`.
