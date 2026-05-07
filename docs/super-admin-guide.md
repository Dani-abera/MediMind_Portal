# Super Admin Guide

This guide is for MediMind platform operators.

## Login

1. Select the **Super Admin** tab on the login screen.
2. Enter your credentials.
3. Complete **TOTP** verification (mandatory — use your authenticator app).

The super-admin workspace has a red accent color and an **ENV** badge in the top bar to distinguish it from other workspaces.

## Dashboard

Shows platform-wide KPIs: total centers, active subscriptions, monthly revenue, total users. Includes a growth line chart and subscription plan donut chart.

A **Pending Alert Banner** appears when there are centers or doctors awaiting review.

## Centers

| Tab | Contents |
|-----|----------|
| All | Every registered center |
| Pending | Centers awaiting approval |
| Active | Approved, operational centers |
| Suspended | Suspended centers |

### Actions

- **Approve** — activates a pending center and sends a welcome email.
- **Reject** — rejects with a required reason message.
- **Suspend** — suspends with a required reason; center staff cannot log in.
- **Reactivate** — restores a suspended center.

Click a center row to open the **Center Detail** (5 tabs: Overview, Subscription, Doctors, Activity, Audit).

## Doctors

Platform-wide doctor list across all centers. Filter by verification status. Actions:

- **Verify License** — marks license as verified after manual review.
- **Suspend** — suspends a doctor platform-wide (across all centers).

## Users

All users (doctors, admins, patients) across the platform. Filter by type and status. The side drawer shows user details and provides:

- Suspend / Reactivate
- Force Logout (invalidates active session immediately)
- Delete (permanent — requires confirmation)

## Subscriptions

All center subscriptions with expiry color-coding: green (>30 days), amber (7–30 days), red (<7 days or expired).

**Change Plan**: select a new plan, confirm effective date and proration.

## Analytics

| Tab | Contents |
|-----|----------|
| Dashboard | Revenue trend, new center growth, subscription mix |
| Revenue | Revenue by center, plan-level breakdown |
| Growth | MoM/YoY center and user growth |

## Audit Log

Platform-wide action log across all centers. Filter by center, actor, action type, and date range. Export to CSV for compliance audits.

## Platform Settings

| Section | What you can configure |
|---------|----------------------|
| Pricing | Per-plan monthly fee |
| Limits | Max doctors/patients/storage per plan |
| Feature Flags | Enable/disable platform features globally |
| Maintenance Mode | Take the platform offline with a custom message |

> **Warning:** Enabling Maintenance Mode will immediately block all user logins.

## Security Notes

- Session auto-expires after 30 minutes of inactivity.
- All actions are recorded in the audit log with your user ID.
- TOTP is mandatory — cannot be disabled for super-admin accounts.
