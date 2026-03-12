# CLAUDE.md — Fintech Crypto Wallet App (Flutter)

> This file is the single source of truth for Claude Code when working on this project.
> Read this file fully before writing any code, making architectural decisions, or suggesting changes.

---

## 🗂 Project Overview

| Field         | Value                                      |
|---------------|--------------------------------------------|
| App Name      | CryptoWallet (MVP)                         |
| Platform      | Flutter (Mobile: iOS + Android, Web)       |
| Backend       | Supabase (Auth + DB + Realtime)            |
| State Mgmt    | Riverpod (v2 — code generation)            |
| Architecture  | Clean Architecture + Feature-First         |
| Design System | Apple-inspired (SF Pro-like, light/dark)   |
| Target SDK    | Flutter 3.22+ / Dart 3.4+                  |
| BTC Data      | CoinGecko API (free tier, real-time price) |
| MVP Scope     | Auth · Wallet · BTC Price · Buy/Sell · Send/Receive · History |

---

## 🏗 Architecture

### Pattern: Clean Architecture + Feature-First

```
lib/
├── core/
│   ├── constants/          # AppColors, AppTypography, AppSizes, AppStrings
│   ├── errors/             # Failure classes, AppException
│   ├── extensions/         # BuildContext, DateTime, String extensions
│   ├── network/            # Dio client, interceptors, API base URL
│   ├── router/             # GoRouter configuration & route names
│   ├── theme/              # AppTheme (light + dark), ThemeExtensions
│   └── utils/              # formatters, validators, currency helpers
│
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── datasources/   # supabase_auth_datasource.dart
│   │   │   └── repositories/  # auth_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/      # user_entity.dart
│   │   │   ├── repositories/  # auth_repository.dart (abstract)
│   │   │   └── usecases/      # sign_in.dart, sign_up.dart, sign_out.dart
│   │   └── presentation/
│   │       ├── providers/     # auth_provider.dart (Riverpod)
│   │       ├── pages/         # login_page.dart, register_page.dart
│   │       └── widgets/       # auth_text_field.dart, social_login_button.dart
│   │
│   ├── wallet/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │       ├── pages/         # wallet_home_page.dart
│   │       └── widgets/       # balance_card.dart, quick_actions_row.dart
│   │
│   ├── market/
│   │   ├── data/
│   │   │   └── datasources/   # coingecko_datasource.dart
│   │   ├── domain/
│   │   │   └── entities/      # btc_price_entity.dart
│   │   └── presentation/
│   │       ├── providers/     # btc_price_provider.dart (StreamProvider, 30s poll)
│   │       └── widgets/       # price_ticker_widget.dart, mini_chart.dart
│   │
│   ├── trade/
│   │   ├── data/
│   │   ├── domain/
│   │   │   └── usecases/      # buy_btc.dart, sell_btc.dart
│   │   └── presentation/
│   │       ├── pages/         # buy_sell_page.dart
│   │       └── widgets/       # amount_input.dart, order_summary_card.dart
│   │
│   ├── transfer/
│   │   ├── data/
│   │   ├── domain/
│   │   │   └── usecases/      # send_btc.dart, receive_btc.dart
│   │   └── presentation/
│   │       ├── pages/         # send_page.dart, receive_page.dart
│   │       └── widgets/       # address_input.dart, qr_display.dart
│   │
│   └── history/
│       ├── data/
│       ├── domain/
│       └── presentation/
│           ├── pages/         # transaction_history_page.dart
│           └── widgets/       # transaction_tile.dart, filter_chips.dart
│
├── shared/
│   ├── widgets/               # AppButton, AppTextField, AppCard, LoadingOverlay
│   │                          # BottomNavBar, AppScaffold, EmptyState, ErrorState
│   └── providers/             # supabase_provider.dart, connectivity_provider.dart
│
└── main.dart                  # ProviderScope → App
```

---

## 📦 pubspec.yaml — Approved Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter

  # State Management
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5

  # Navigation
  go_router: ^14.0.0

  # Backend
  supabase_flutter: ^2.5.0

  # Networking
  dio: ^5.4.3
  retrofit: ^4.1.0

  # UI
  flutter_svg: ^2.0.10+1
  cached_network_image: ^3.3.1
  shimmer: ^3.0.0
  fl_chart: ^0.67.0          # Price chart
  qr_flutter: ^4.1.0         # QR code for receive address

  # Security & Crypto
  flutter_secure_storage: ^9.0.0
  local_auth: ^2.2.0         # Biometric lock

  # Utils
  intl: ^0.19.0
  freezed_annotation: ^2.4.1
  json_annotation: ^4.9.0
  equatable: ^2.0.5
  dartz: ^0.10.1              # Either<Failure, T>
  logger: ^2.3.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: ^2.4.9
  riverpod_generator: ^2.4.0
  freezed: ^2.5.2
  json_serializable: ^6.8.0
  retrofit_generator: ^8.1.0
  flutter_lints: ^4.0.0
  mocktail: ^1.0.4
```

---

## 🔐 Supabase Schema (MVP)

### Tables

```sql
-- profiles (extends auth.users)
create table profiles (
  id uuid references auth.users(id) primary key,
  full_name text,
  avatar_url text,
  created_at timestamptz default now()
);

-- wallets
create table wallets (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references profiles(id) not null unique,
  usd_balance numeric(18,2) default 0.00,
  btc_balance numeric(18,8) default 0.00000000,
  btc_address text unique not null,   -- mock address for MVP
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- transactions
create table transactions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references profiles(id) not null,
  type text check (type in ('buy','sell','send','receive')) not null,
  amount_btc numeric(18,8),
  amount_usd numeric(18,2),
  btc_price_at_time numeric(18,2),
  from_address text,
  to_address text,
  status text check (status in ('pending','completed','failed')) default 'pending',
  created_at timestamptz default now()
);

-- RLS Policies (all tables)
alter table profiles enable row level security;
alter table wallets enable row level security;
alter table transactions enable row level security;

-- Users can only read/write their own data
create policy "own_profile" on profiles for all using (auth.uid() = id);
create policy "own_wallet" on wallets for all using (auth.uid() = user_id);
create policy "own_transactions" on transactions for all using (auth.uid() = user_id);
```

---

## 🌐 External APIs

### CoinGecko (BTC Price)
```
Base URL : https://api.coingecko.com/api/v3
Endpoint : GET /simple/price?ids=bitcoin&vs_currencies=usd&include_24hr_change=true
Polling  : Every 30 seconds via Riverpod StreamProvider + Timer
No API key required for free tier (rate limit: 30 calls/min)
```

### MVP Mock — No Real Blockchain
- BTC addresses are randomly generated UUIDs stored in `wallets.btc_address`
- Buy/Sell updates `usd_balance` and `btc_balance` in Supabase at current BTC price
- Send/Receive updates balances between users in the same Supabase instance
- No real blockchain transactions in MVP

---

## 🎨 Design System

### Colors
```dart
// core/constants/app_colors.dart
static const primary     = Color(0xFF007AFF);  // iOS Blue
static const success     = Color(0xFF34C759);  // iOS Green
static const danger      = Color(0xFFFF3B30);  // iOS Red
static const warning     = Color(0xFFFF9500);  // iOS Orange
static const surface     = Color(0xFFF2F2F7);  // iOS Gray 6
static const label       = Color(0xFF1C1C1E);  // iOS Label
static const secondLabel = Color(0xFF8E8E93);  // iOS Secondary Label
static const btcOrange   = Color(0xFFF7931A);  // Bitcoin brand
```

### Typography
```dart
// Use system font (SF Pro on iOS, Roboto on Android, Inter on Web)
// Sizes: 34 (largeTitle), 28 (title1), 22 (title2), 17 (body), 15 (subhead), 13 (caption)
// Weight: .w700 for balances/prices, .w500 for labels, .w400 for body
```

### Spacing Grid: 4px base unit (4, 8, 12, 16, 20, 24, 32, 48)

### Card Style
```dart
BoxDecoration(
  color: Colors.white,               // dark: Color(0xFF1C1C1E)
  borderRadius: BorderRadius.circular(16),
  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 20, offset: Offset(0,4))],
)
```

---

## 🗺 Navigation (GoRouter)

```
/                      → Redirect (auth guard)
/login                 → LoginPage
/register              → RegisterPage
/home                  → WalletHomePage (shell route)
  /home/history        → TransactionHistoryPage
  /home/buy-sell       → BuySellPage
  /home/send           → SendPage
  /home/receive        → ReceivePage
  /home/profile        → ProfilePage
```

**Auth Guard**: `GoRouter.redirect` checks Supabase `authStateChanges`. Unauthenticated → `/login`.

---

## 🔑 Key Providers (Riverpod)

```dart
// Auth state — watch this everywhere
@riverpod
Stream<AuthState> authState(AuthStateRef ref)

// Current user wallet
@riverpod
Future<WalletEntity> userWallet(UserWalletRef ref)

// BTC price — polls every 30s
@riverpod
Stream<BtcPriceEntity> btcPrice(BtcPriceRef ref)

// Transaction history — paginated
@riverpod
Future<List<TransactionEntity>> transactionHistory(
  TransactionHistoryRef ref, {int page = 0}
)
```

---

## 🌍 Web Support

Flutter Web is **first-class** in this project:

- Use `kIsWeb` guards where platform behavior differs
- Avoid `dart:io` — use `universal_io` or conditional imports
- Web layout: max content width `480px`, centered, mobile-shell style
- Avoid plugins that don't support web: `local_auth` → graceful fallback on web
- `flutter_secure_storage` on web uses `localStorage` — document this clearly
- Use `url_strategy` package: `usePathUrlStrategy()` in `main.dart`
- Web entrypoint: `web/index.html` should have proper meta tags and favicon

---

## 🧪 Testing Strategy

| Layer        | Tool           | Coverage Target |
|--------------|----------------|-----------------|
| Domain       | `flutter_test` | 90%+            |
| Repositories | `mocktail`     | 80%+            |
| Providers    | `riverpod`     | 70%+            |
| UI (smoke)   | `flutter_test` | Key flows only  |

---

## ⚙️ Environment & Config

```
.env.local (never commit)
├── SUPABASE_URL=
├── SUPABASE_ANON_KEY=
└── COINGECKO_BASE_URL=https://api.coingecko.com/api/v3

Use flutter_dotenv or --dart-define for env injection.
```

---

## 🚀 Build & Run Commands

```bash
# Install dependencies
flutter pub get

# Generate code (Riverpod, Freezed, Retrofit)
dart run build_runner build --delete-conflicting-outputs

# Run on device
flutter run                          # default device
flutter run -d chrome                # web

# Build for production
flutter build apk --release          # Android
flutter build ios --release          # iOS
flutter build web --release          # Web

# Run tests
flutter test
```

---

## 🚫 Hard Rules (Claude must follow these)

1. **Never** use `setState` in pages — always use Riverpod providers
2. **Never** put business logic in widgets — use UseCases in domain layer
3. **Never** call Supabase/Dio directly from UI — go through Repository → UseCase → Provider
4. **Never** hardcode colors, strings, or sizes — use `AppColors`, `AppStrings`, `AppSizes`
5. **Always** return `Either<Failure, T>` from repositories using `dartz`
6. **Always** use `AsyncValue` states in Riverpod (`loading`, `data`, `error`)
7. **Always** handle errors gracefully — show `ErrorState` widget, never crash
8. **Always** use `const` constructors where possible
9. **Always** separate `web/` and `mobile/` specific logic with conditional imports or `kIsWeb`
10. **Never** store sensitive data (keys, tokens) in plain `SharedPreferences` — use `flutter_secure_storage`

---

## 📋 MVP Feature Checklist

- [ ] Auth: Sign up / Sign in (email+password via Supabase)
- [ ] Auth: Persist session, auto-login on re-open
- [ ] Wallet: Display USD balance + BTC balance
- [ ] Market: Live BTC/USD price with 24h % change
- [ ] Trade: Buy BTC (USD → BTC conversion at live price)
- [ ] Trade: Sell BTC (BTC → USD at live price)
- [ ] Transfer: Send BTC to another wallet address (within app)
- [ ] Transfer: Receive BTC — show QR + copy address
- [ ] History: Full transaction list, filterable by type
- [ ] UI: Dark mode support
- [ ] UI: Web responsive layout

---

## 🔮 Post-MVP Scaling Notes

- Replace mock BTC engine with real exchange API (Coinbase Advanced, Kraken)
- Add real on-chain wallet (WalletConnect, web3dart)
- Push notifications (Supabase + FCM) for transaction alerts
- Multi-asset support (ETH, SOL, USDT)
- KYC/AML integration
- Portfolio analytics with historical charts

---

## 🔌 Supabase MCP Integration

This project uses the Supabase MCP server for direct database management and edge function deployment.

### Configuration

Supabase MCP is configured with:
- **Project Ref**: Stored in MCP settings
- **Auth Token**: Header-based authentication for secure API access

### Available MCP Commands

| Command | Description |
|---------|-------------|
| `mcp__supabase__list_tables` | List all tables in specified schemas |
| `mcp__supabase__execute_sql` | Execute raw SQL queries (read operations) |
| `mcp__supabase__apply_migration` | Apply DDL migrations to the database |
| `mcp__supabase__list_migrations` | List all applied migrations |
| `mcp__supabase__list_extensions` | List installed Postgres extensions |
| `mcp__supabase__get_logs` | Fetch logs for specific services (auth, api, storage, etc.) |
| `mcp__supabase__get_advisors` | Get security/performance recommendations |
| `mcp__supabase__list_edge_functions` | List deployed edge functions |
| `mcp__supabase__get_edge_function` | Get edge function source code |
| `mcp__supabase__deploy_edge_function` | Deploy new/updated edge functions |
| `mcp__supabase__create_branch` | Create development branch with isolated DB |
| `mcp__supabase__list_branches` | List all dev branches |
| `mcp__supabase__merge_branch` | Merge branch migrations to production |
| `mcp__supabase__rebase_branch` | Rebase branch on latest production |
| `mcp__supabase__reset_branch` | Reset branch to specific migration version |
| `mcp__supabase__delete_branch` | Delete a development branch |
| `mcp__supabase__get_project_url` | Get the Supabase project API URL |
| `mcp__supabase__get_publishable_keys` | Get API keys (anon/publishable) |
| `mcp__supabase__generate_typescript_types` | Generate TS types from schema |
| `mcp__supabase__search_docs` | Search Supabase documentation |

### Workflow

1. **Development**: Create a branch with `create_branch` for feature work
2. **Schema Changes**: Write migration SQL, apply with `apply_migration`
3. **Testing**: Test on branch, verify with `execute_sql` and `get_logs`
4. **Deploy**: `merge_branch` to push migrations and edge functions to production

### Security Notes

- MCP uses header token authentication — never share or commit tokens
- DDL operations should use `apply_migration`, not `execute_sql`
- RLS policies must be enabled on all tables (see schema section)
- Run `get_advisors` periodically for security/performance checks

---

*Last updated: March 2026 | Stack: Flutter 3.22 · Riverpod 2 · Supabase · CoinGecko*
