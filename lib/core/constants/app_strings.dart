/// App-wide string constants
class AppStrings {
  AppStrings._();

  // App info
  static const String appName = 'CryptoWallet';
  static const String appVersion = '1.0.0';

  // Auth
  static const String signIn = 'Sign In';
  static const String signUp = 'Sign Up';
  static const String signOut = 'Sign Out';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String fullName = 'Full Name';
  static const String confirmPassword = 'Confirm Password';
  static const String forgotPassword = 'Forgot Password?';
  static const String noAccount = "Don't have an account? ";
  static const String hasAccount = "Already have an account? ";
  static const String register = 'Register';
  static const String login = 'Login';

  // Wallet
  static const String wallet = 'Wallet';
  static const String balance = 'Balance';
  static const String usdBalance = 'USD Balance';
  static const String btcBalance = 'BTC Balance';
  static const String totalValue = 'Total Value';
  static const String btcAddress = 'BTC Address';
  static const String copyAddress = 'Copy Address';
  static const String addressCopied = 'Address copied to clipboard';

  // Market
  static const String market = 'Market';
  static const String bitcoin = 'Bitcoin';
  static const String btc = 'BTC';
  static const String usd = 'USD';
  static const String price = 'Price';
  static const String livePrice = 'Live Price';
  static const String twentyFourHourChange = '24h Change';

  // Trade
  static const String buy = 'Buy';
  static const String sell = 'Sell';
  static const String buyBtc = 'Buy BTC';
  static const String sellBtc = 'Sell BTC';
  static const String amount = 'Amount';
  static const String quantity = 'Quantity';
  static const String total = 'Total';
  static const String orderSummary = 'Order Summary';
  static const String confirmOrder = 'Confirm Order';
  static const String placeOrder = 'Place Order';

  // Transfer
  static const String send = 'Send';
  static const String receive = 'Receive';
  static const String sendBtc = 'Send BTC';
  static const String receiveBtc = 'Receive BTC';
  static const String recipientAddress = 'Recipient Address';
  static const String yourAddress = 'Your Address';
  static const String enterAddress = 'Enter BTC address';
  static const String scanQr = 'Scan QR Code';
  static const String shareAddress = 'Share Address';

  // History
  static const String history = 'History';
  static const String transactions = 'Transactions';
  static const String transactionHistory = 'Transaction History';
  static const String buyTransaction = 'Buy';
  static const String sellTransaction = 'Sell';
  static const String sendTransaction = 'Send';
  static const String receiveTransaction = 'Receive';
  static const String pending = 'Pending';
  static const String completed = 'Completed';
  static const String failed = 'Failed';
  static const String noTransactions = 'No transactions yet';

  // Profile
  static const String profile = 'Profile';
  static const String settings = 'Settings';
  static const String darkMode = 'Dark Mode';
  static const String biometricLock = 'Biometric Lock';
  static const String notifications = 'Notifications';
  static const String security = 'Security';
  static const String about = 'About';
  static const String logout = 'Logout';

  // Common
  static const String cancel = 'Cancel';
  static const String confirm = 'Confirm';
  static const String save = 'Save';
  static const String delete = 'Delete';
  static const String edit = 'Edit';
  static const String done = 'Done';
  static const String retry = 'Retry';
  static const String loading = 'Loading...';
  static const String error = 'Error';
  static const String success = 'Success';
  static const String close = 'Close';

  // Error messages
  static const String genericError = 'Something went wrong. Please try again.';
  static const String networkError = 'Network error. Check your connection.';
  static const String authError = 'Authentication failed. Please try again.';
  static const String insufficientBalance = 'Insufficient balance.';
  static const String invalidAddress = 'Invalid address.';
  static const String invalidAmount = 'Invalid amount.';

  // Success messages
  static const String orderPlaced = 'Order placed successfully!';
  static const String sentSuccessfully = 'Sent successfully!';
  static const String copiedToClipboard = 'Copied to clipboard!';
}
