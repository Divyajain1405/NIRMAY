import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

// toggle this if you want the app to remember groups between restarts
// set to false for now (mocky)
const bool kEnableGroupPersistence = false; // set true to persist post restart

// basic text styles used throughout — nothing fancy, just consistent
const TextStyle kTitle = TextStyle(
  fontSize: 20,
  fontWeight: FontWeight.w800,
  color: Colors.black87,
);

const TextStyle kSubtitle = TextStyle(fontSize: 15, color: Colors.black87);

const TextStyle kSmallMuted = TextStyle(fontSize: 13, color: Colors.grey);

const TextStyle kButtonText = TextStyle(
  fontSize: 15,
  fontWeight: FontWeight.w600,
);

const TextStyle kCardHeading = TextStyle(
  fontSize: 18,
  fontWeight: FontWeight.w700,
  color: Colors.black87,
);

// container background & text color used in cards
const Color kContainerBg = MyApp.containerBg;
const Color kContainerText = Colors.black87;

const TextStyle kAppBarTitle = TextStyle(
  fontSize: 20,
  fontWeight: FontWeight.w700,
  color: Colors.white,
);

// entry point — normal Flutter main
void main() => runApp(const MyApp());

// Main app widget — holds theme and colors
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // App palette — named casually
  static const Color saffron = Color(0xFFFF9933);
  static const Color agriGreen = Color(0xFF0F9D58);
  static const Color containerBg = Color(
    0xFFF3F6F1,
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nirmay',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: MyApp.agriGreen,
          primary: MyApp.agriGreen,
        ),
        primaryColor: MyApp.agriGreen,

        // AppBar tweaks — keep it simple and consistent
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: false,
          toolbarHeight: 56.0, // consistent AppBar height across all pages
          titleTextStyle: kAppBarTitle,
          iconTheme: IconThemeData(color: Colors.white),
        ),

        // Use Google Fonts (Poppins) for a chilled look
        textTheme: GoogleFonts.poppinsTextTheme(ThemeData.light().textTheme),

        // Buttons default styling so buttons look similar everywhere
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 2,
            backgroundColor: MyApp.agriGreen,
            foregroundColor: Colors.white,
            textStyle: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),

        // Inputs (text fields) styling — neat rounded boxes
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: MyApp.agriGreen, width: 2),
          ),
        ),

        // app background
        scaffoldBackgroundColor: Colors.white,
      ),

      home: const SplashPage(),
    );
  }
}

// Splash page — shows your splash image and app name, then moves on.
// kept minimal — 2s and then navigate to language selector.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    // show splash for 2 seconds then replace with language selector
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LanguageSelector()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final double imgWidth = mq.size.width * 0.78; // keeps image centered with nice padding

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // image (use your provided asset)
                SizedBox(
                  width: imgWidth,
                  child: Image.asset(
                    'lib/images/splash_intro.png',
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 18),
                // small subtle app name (keeps existing design)
                Text('Nirmay', style: kTitle.copyWith(fontSize: 22)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Language selector screen — grid of language circles.
// tapping English goes to login/register, other languages show a snack (mock).
class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> langs = [
      {"label": "English", "short": "Eng"},
      {"label": "हिंदी", "short": "हिं"},
      {"label": "Assamese", "short": "অ"},
      {"label": "Bengali", "short": "বা"},
      {"label": "Gujarati", "short": "ગુ"},
      {"label": "Kannada", "short": "ಕ"},
      {"label": "Malayalam", "short": "മ"},
      {"label": "Marathi", "short": "म"},
      {"label": "Odia", "short": "ଓ"},
      {"label": "Punjabi", "short": "ਪੰ"},
      {"label": "Tamil", "short": "த"},
      {"label": "Telugu", "short": "తె"},
    ];

    final mq = MediaQuery.of(context);
    final double width = mq.size.width;
    final double height = mq.size.height;

    const double horizontalPadding = 16.0;
    const double spacing = 18.0;

    // Choose columns: use 3 for narrow phones, 4 for wider phones/tablets
    final int cols = (width >= 420) ? 4 : 3;

    // compute available item width and main axis extent
    final double itemWidth =
        (width - horizontalPadding * 2 - (cols - 1) * spacing) / cols;

    // circle diameter: larger fraction of itemWidth and wider clamp range so circles feel bigger
    final double circleDiameter = (itemWidth * 0.78)
        .clamp(72.0, 140.0)
        .toDouble();

    // label area height and total item height
    const double labelArea = 44.0; // allows two lines comfortably
    final double itemHeight = circleDiameter + labelArea;

    // center grid vertically by computing top padding so it visually fills screen
    final int rows = (langs.length / cols).ceil();
    final double totalGridHeight = rows * itemHeight + (rows - 1) * spacing;
    final double topPaddingBase = 24.0;
    final double availableVertical = height - kToolbarHeight - mq.padding.top;
    final double topPadding = (availableVertical > totalGridHeight)
        ? ((availableVertical - totalGridHeight) / 2)
        : topPaddingBase;

    final TextStyle labelStyle = kSubtitle.copyWith(color: Colors.black87);

    // fun little palette to make circles not all the same
    final List<Color> palette = [
      const Color(0xFFE3F2FD), // light blue
      const Color(0xFFFCE4EC), // pink
      const Color(0xFFE8F5E9), // green
      const Color(0xFFFFF3E0), // orange
      const Color(0xFFF3E5F5), // purple
      const Color(0xFFE0F7FA), // cyan
    ];

    return Scaffold(
      appBar: AppBar(
        leading: Navigator.of(context).canPop()
            ? IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        )
            : null,
        title: Text(
          "Choose Your Language",
          style: kCardHeading.copyWith(color: MyApp.agriGreen, fontSize: 22),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: GridView.builder(
        padding: EdgeInsets.only(
          left: horizontalPadding,
          right: horizontalPadding,
          top: topPadding,
          bottom: 24,
        ),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: cols,
          crossAxisSpacing: spacing,
          mainAxisSpacing: spacing,
          mainAxisExtent: itemHeight,
        ),
        itemCount: langs.length,
        itemBuilder: (ctx, i) {
          final lang = langs[i];
          final Color bg = palette[i % palette.length];

          // dynamic short-code font sizing:
          // single-codepoint scripts tend to look visually larger; reduce their font slightly
          final int runeCount = lang["short"]!.runes.length;
          final double fontSize = (runeCount == 1)
              ? (circleDiameter * 0.30).clamp(14.0, 28.0).toDouble()
              : (circleDiameter * 0.34).clamp(18.0, 34.0).toDouble();
          final TextStyle shortStyle = kTitle.copyWith(
            fontSize: fontSize,
            color: Colors.black87,
          );

          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // circular tile
                Material(
                  shape: const CircleBorder(),
                  color: bg,
                  elevation: 0.6,
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () {
                      if (lang["label"] == "English") {
                        if (Navigator.of(context).canPop()) {
                          Navigator.of(context).pop();
                        } else {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const LoginRegisterScreen(),
                            ),
                          );
                        }
                      } else {
                        // other languages are mocked — just show a snack
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "${lang["label"]} not implemented (mock)",
                            ),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    child: SizedBox(
                      width: circleDiameter,
                      height: circleDiameter,
                      child: Center(
                        child: Text(
                          lang["short"]!,
                          style: shortStyle,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // label (2 lines allowed; centered)
                SizedBox(
                  width: itemWidth,
                  child: Text(
                    lang["label"]!,
                    style: labelStyle,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Login / Register screen — has role selector, tabs for Login/Register,
// social buttons and mock navigation into the app.
class LoginRegisterScreen extends StatefulWidget {
  const LoginRegisterScreen({super.key});

  static const Color agriGreen = MyApp.agriGreen;
  static const Color saffron = MyApp.saffron;

  @override
  State<LoginRegisterScreen> createState() => _LoginRegisterScreenState();
}

class _LoginRegisterScreenState extends State<LoginRegisterScreen> {
  // role value used by the forms to decide post-login/register navigation
  final ValueNotifier<String> _roleNotifier = ValueNotifier<String>('Farmer');

  @override
  void dispose() {
    _roleNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color agriGreen = MyApp.agriGreen;
    const Color saffron = MyApp.saffron;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: kContainerBg,
          leading: Navigator.canPop(context)
              ? IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () => Navigator.of(context).pop(),
          )
              : null,
          elevation: 0,
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Compact header (small height)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 52,
                      height: 52,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          'lib/images/logo.png',
                          fit: BoxFit.cover,
                          width: 52,
                          height: 52,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Nirmay', style: kTitle.copyWith(fontSize: 20)),
                        const SizedBox(height: 2),
                        Text('Welcome!', style: kSubtitle),
                      ],
                    ),
                    const Spacer(),
                  ],
                ),
              ),

              // Main card area — expand to fill vertical space
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  child: Card(
                    color: kContainerBg,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: Column(
                        children: [
                          // Role selector row (small chips)
                          _RoleSelector(roleNotifier: _roleNotifier),

                          const SizedBox(height: 12),

                          // Segmented TabBar — active tab fills whole tab
                          Container(
                            height: 52,
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: TabBar(
                              indicatorSize: TabBarIndicatorSize.tab,
                              indicatorPadding: EdgeInsets.zero,
                              labelPadding: EdgeInsets.zero,
                              indicator: BoxDecoration(
                                color: agriGreen,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              labelColor: Colors.white,
                              unselectedLabelColor: Colors.black87,
                              tabs: [
                                Tab(
                                  child: Center(
                                    child: Text('Login', style: kButtonText),
                                  ),
                                ),
                                Tab(
                                  child: Center(
                                    child: Text('Register', style: kButtonText),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Tab contents take the remaining vertical space inside the card
                          Expanded(
                            child: TabBarView(
                              physics: const NeverScrollableScrollPhysics(),
                              children: [
                                _LoginForm(
                                  agriGreen: agriGreen,
                                  roleNotifier: _roleNotifier,
                                ),
                                _RegisterForm(
                                  agriGreen: agriGreen,
                                  roleNotifier: _roleNotifier,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Divider + "or continue with"
                          Row(
                            children: [
                              const Expanded(child: Divider()),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10.0,
                                ),
                                child: Text(
                                  'or continue with',
                                  style: kSmallMuted,
                                ),
                              ),
                              const Expanded(child: Divider()),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Social buttons — mocked (just enter app)
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => _enterAppDirectly(context),
                                  icon: Image.asset(
                                    'lib/images/google.png',
                                    height: 20,
                                    width: 20,
                                  ),
                                  label: const Text('Google'),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    foregroundColor: Colors.black87,
                                    side: BorderSide(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => _enterAppDirectly(context),
                                  icon: Image.asset(
                                    'lib/images/apple.png',
                                    height: 20,
                                    width: 20,
                                  ),
                                  label: const Text('Apple'),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    foregroundColor: Colors.black87,
                                    side: BorderSide(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),
                          Text(
                            'This is a mockup — no real authentication',
                            style: kSmallMuted,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // simple mock navigation based on role — Farmer -> HomeMock, Vet -> VetPending, else -> RegulatorPending
  void _enterAppDirectly(BuildContext context) {
    final role = _roleNotifier.value;
    if (role == 'Farmer') {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeMock()),
            (route) => false,
      );
    } else if (role == 'Veterinarian') {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const VetPending()),
            (route) => false,
      );
    } else {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const RegulatorPending()),
            (route) => false,
      );
    }
  }
}

// --- Role selector small widgets (insert before _LoginForm class) ---
// tiny widgets that let the user pick a role: Farmer / Veterinarian / Regulator
// I wrote comments everywhere so it's obvious what's going on — kept the code the same.
class _RoleSelector extends StatelessWidget {
  final ValueNotifier<String> roleNotifier;
  const _RoleSelector({required this.roleNotifier});

  @override
  Widget build(BuildContext context) {
    // listen to the notifier and rebuild when role changes
    return ValueListenableBuilder<String>(
      valueListenable: roleNotifier,
      builder: (ctx, role, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Farmer chip
            _RoleChip(
              label: 'Farmer',
              selected: role == 'Farmer',
              onTap: () => roleNotifier.value = 'Farmer',
            ),
            const SizedBox(width: 8),
            // Veterinarian chip
            _RoleChip(
              label: 'Veterinarian',
              selected: role == 'Veterinarian',
              onTap: () => roleNotifier.value = 'Veterinarian',
            ),
            const SizedBox(width: 8),
            // Regulator chip
            _RoleChip(
              label: 'Regulator',
              selected: role == 'Regulator',
              onTap: () => roleNotifier.value = 'Regulator',
            ),
          ],
        );
      },
    );
  }
}

// a small reusable chip used by the row above
class _RoleChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _RoleChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // active color = app green, same as before
    final Color activeColor = MyApp.agriGreen;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          // highlight when selected, otherwise light grey
          color: selected ? activeColor : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
          boxShadow: selected
              ? [
            // small shadow for the selected chip — subtle
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ]
              : null,
        ),
        child: Text(
          label,
          style: kButtonText.copyWith(
            color: selected ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }
}

// -------- Login form (no logic changes, just added comments) --------
class _LoginForm extends StatefulWidget {
  final Color agriGreen;
  final ValueNotifier<String> roleNotifier;
  const _LoginForm({required this.agriGreen, required this.roleNotifier});

  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  // controllers & focus node for phone/password fields
  final _phoneController = TextEditingController();
  final _passController = TextEditingController();
  final FocusNode _phoneFocusNode = FocusNode();
  String? _phoneError;

  // small helper to refresh button enabled state
  void _updateButtonState() {
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    // watch focus changes so we can validate phone when user leaves the field
    _phoneFocusNode.addListener(_onPhoneFocusChange);
    // update button state when text changes
    _passController.addListener(_updateButtonState);
    _phoneController.addListener(_updateButtonState);
  }

  // phone validation: when focus is lost, ensure 10 digits or show error
  void _onPhoneFocusChange() {
    if (!_phoneFocusNode.hasFocus) {
      final text = _phoneController.text.trim();
      if (text.isNotEmpty && text.length != 10) {
        if (mounted) {
          setState(() {
            _phoneError = 'Please enter a valid 10-digit phone number';
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _phoneError = null;
          });
        }
      }
    }
  }

  @override
  @override
  void dispose() {
    // cleanup listeners & controllers
    _phoneFocusNode.removeListener(_onPhoneFocusChange);
    _phoneFocusNode.dispose();

    _phoneController.removeListener(_updateButtonState);
    _phoneController.dispose();

    _passController.removeListener(_updateButtonState);
    _passController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // keep it scrollable so keyboard doesn't hide stuff
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // phone input (Indian +91 prefix, digits only)
          TextFormField(
            controller: _phoneController,
            focusNode: _phoneFocusNode,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
            decoration: InputDecoration(
              labelText: 'Phone',
              errorText: _phoneError,
              prefix: Padding(
                padding: const EdgeInsets.only(right: 6.0, left: 6.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🇮🇳', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 6),
                    Text('+91', style: kButtonText),
                    const SizedBox(width: 8),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // password field
          TextFormField(
            controller: _passController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Password',
              prefixIcon: Icon(Icons.lock_outline),
            ),
          ),
          const SizedBox(height: 16),

          // login button — enabled only when phone is 10 digits and password not empty
          ElevatedButton(
            onPressed:
            (_phoneController.text.trim().length == 10 &&
                _passController.text.trim().isNotEmpty)
                ? _onLoginPressed
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.agriGreen,
              foregroundColor: Colors.white,
            ),
            child: Text(
              'Login',
              style: kButtonText.copyWith(color: Colors.white),
            ),
          ),

          const SizedBox(height: 8),
          // forgot password (mock)
          TextButton(
            onPressed: _onForgotPressed,
            child: Text(
              'Forgot password?',
              style: kSmallMuted.copyWith(color: const Color(0xFF5C6BC0)),
            ),
          ),
        ],
      ),
    );
  }

  // mock navigation on successful login — same as before
  void _onLoginPressed() {
    final role = widget.roleNotifier.value;
    if (role == 'Farmer') {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeMock()),
            (route) => false,
      );
    } else if (role == 'Veterinarian') {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const VetPending()),
            (route) => false,
      );
    } else {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const RegulatorPending()),
            (route) => false,
      );
    }
  }

  // simple mock for forgot password
  void _onForgotPressed() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Mock: Password reset not implemented'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

// --- OTP input row widget: paste at top-level in main.dart (outside any classes) ---
// little widget that renders N single-character boxes for OTP input.
// behaviour: auto-moves focus, supports backspace to go back.
class OtpInputRow extends StatefulWidget {
  final int length;
  final void Function(String) onCompleted;
  final EdgeInsets padding;

  const OtpInputRow({
    super.key,
    required this.length,
    required this.onCompleted,
    this.padding = const EdgeInsets.symmetric(vertical: 16.0),
  });

  @override
  State<OtpInputRow> createState() => _OtpInputRowState();
}

class _OtpInputRowState extends State<OtpInputRow> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    // create controllers & focus nodes based on requested length
    _controllers = List.generate(widget.length, (_) => TextEditingController());
    _focusNodes = List.generate(widget.length, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  // when a box gets text, keep only last char and move to next box
  void _onChanged(String value, int index) {
    if (value.isNotEmpty) {
      final ch = value.trim().characters.last;
      _controllers[index].text = ch;
      _controllers[index].selection = const TextSelection.collapsed(offset: 1);

      if (index + 1 < widget.length) {
        FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
      } else {
        final code = _controllers.map((c) => c.text).join();
        widget.onCompleted(code);
        _focusNodes[index].unfocus();
      }
    }
  }

  // handle physical keyboard backspace to jump back
  KeyEventResult _onKey(FocusNode node, KeyEvent event, int index) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.backspace) {
        final text = _controllers[index].text;
        if (text.isEmpty && index > 0) {
          FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
          _controllers[index - 1].clear();
        }
      }
    }
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: widget.padding,
      child: Center(
        child: IntrinsicWidth(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.length, (index) {
              return Padding(
                padding: EdgeInsets.only(
                  right: index == widget.length - 1 ? 0 : 12.0,
                ),
                child: SizedBox(
                  width: 52,
                  height: 56,
                  child: Focus(
                    focusNode: _focusNodes[index],
                    onKeyEvent: (node, event) => _onKey(node, event, index),
                    child: TextField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLength: 1,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(1),
                      ],
                      decoration: InputDecoration(
                        counterText: '',
                        filled: true,
                        fillColor: Colors.transparent,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: theme.dividerColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ).borderSide,
                        ),
                      ),
                      onChanged: (v) => _onChanged(v, index),
                      autofocus: index == 0,
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// -------- Register form (same logic, comments added) --------
class _RegisterForm extends StatefulWidget {
  final Color agriGreen;
  final ValueNotifier<String> roleNotifier;
  const _RegisterForm({required this.agriGreen, required this.roleNotifier});

  @override
  State<_RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<_RegisterForm> {
  final _phoneController = TextEditingController();
  final _passController = TextEditingController();
  final FocusNode _phoneFocusNode = FocusNode();
  String? _phoneError;

  void _updateButtonState() {
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _passController.addListener(_updateButtonState);
    _phoneController.addListener(_updateButtonState);
    _phoneFocusNode.addListener(_onPhoneFocusChange);
  }

  void _onPhoneFocusChange() {
    if (!_phoneFocusNode.hasFocus) {
      final text = _phoneController.text.trim();
      if (text.isNotEmpty && text.length != 10) {
        if (mounted) {
          setState(() {
            _phoneError = 'Please enter a valid 10-digit phone number';
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _phoneError = null;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _phoneFocusNode.removeListener(_onPhoneFocusChange);
    _phoneFocusNode.dispose();
    _phoneController.removeListener(_updateButtonState);
    _phoneController.dispose();
    _passController.removeListener(_updateButtonState);
    _passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _phoneController,
            focusNode: _phoneFocusNode,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
            decoration: InputDecoration(
              labelText: 'Phone',
              errorText: _phoneError,
              prefix: Padding(
                padding: const EdgeInsets.only(right: 6.0, left: 6.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🇮🇳', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 6),
                    Text('+91', style: kButtonText),
                    const SizedBox(width: 8),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),
          TextFormField(
            controller: _passController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Create Password',
              prefixIcon: Icon(Icons.lock_outline),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed:
            (_phoneController.text.trim().length == 10 &&
                _passController.text.trim().isNotEmpty)
                ? _onRegisterPressed
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.agriGreen,
              foregroundColor: Colors.white,
            ),
            child: Text(
              'Register & Verify OTP',
              style: kButtonText.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // shows a dialog to enter OTP (mock), then navigates like login
  Future<void> _onRegisterPressed() async {
    final TextEditingController otpController = TextEditingController();

    final bool? result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dlgContext) {
        return StatefulBuilder(
          builder: (sbContext, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              title: Text('Verify your phone', style: kTitle),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Enter the code sent to your phone.', style: kSubtitle),
                  const SizedBox(height: 12),
                  TextField(
                    controller: otpController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    decoration: const InputDecoration(
                      counterText: '',
                      labelText: 'OTP',
                    ),
                    onChanged: (_) {
                      setState(() {});
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dlgContext).pop(false);
                  },
                  child: Text('Cancel', style: kButtonText),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.agriGreen,
                  ),
                  onPressed: otpController.text.trim().isNotEmpty
                      ? () {
                    Navigator.of(dlgContext).pop(true);
                  }
                      : null,
                  child: Text(
                    'Verify',
                    style: kButtonText.copyWith(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    FocusScope.of(context).unfocus();
    await Future.delayed(const Duration(milliseconds: 50));
    otpController.dispose();

    if (result == true && mounted) {
      final role = widget.roleNotifier.value;
      if (role == 'Farmer') {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomeMock()),
              (route) => false,
        );
      } else if (role == 'Veterinarian') {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const VetPending()),
              (route) => false,
        );
      } else {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const RegulatorPending()),
              (route) => false,
        );
      }
    }
  }
}

// Vet onboarding placeholder — mock page with notes.
// kept simple, lots of comments so it's easy to follow.
class VetPending extends StatelessWidget {
  const VetPending({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title styled with app bar title style
        title: Text('Veterinarian — Next step', style: kAppBarTitle),
        backgroundColor: MyApp.agriGreen,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // top header visual — saffron-ish box + icon + short text
              Row(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: MyApp.saffron.withAlpha(242), // slight transparency
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.medical_services_outlined,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // main heading
                        Text('Veterinarian onboarding', style: kTitle),
                        const SizedBox(height: 6),
                        // brief subtitle explaining this is a mock
                        Text(
                          'This mock shows what the vet onboarding would include. The next step is not implemented here.',
                          style: kSubtitle,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // card listing what would be collected in a real flow
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: const [
                      Text(
                        'What would be collected (mock):',
                        style: kCardHeading,
                      ),
                      SizedBox(height: 10),
                      Text('- Professional credentials & registration number'),
                      SizedBox(height: 6),
                      Text(
                        '- Clinic / practice details (name, address, contact)',
                      ),
                      SizedBox(height: 6),
                      Text('- Areas of specialization and availability'),
                      SizedBox(height: 6),
                      Text(
                        '- Agreement to professional code (mock verification required)',
                        style: TextStyle(height: 1.2),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // card with mock flow notes — explains why this is a dead-end here
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: const [
                      Text('Mock flow notes', style: kCardHeading),
                      SizedBox(height: 8),
                      Text(
                        '• Vet accounts require manual verification in a real app.\n'
                            '• In this mock the vet flow is intentionally a dead-end page.\n'
                            '• Actions such as scheduling or adding prescriptions are not available here.',
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // back button to return to login/register
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: MyApp.agriGreen,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => const LoginRegisterScreen(),
                    ),
                  );
                },
                child: Text(
                  'Back to Login / Register',
                  style: kButtonText.copyWith(color: Colors.white),
                ),
              ),

              const SizedBox(height: 10),

              // little muted hint so users know this is just a mock
              Text(
                'Note: This is a mock. Vet onboarding not implemented.',
                textAlign: TextAlign.center,
                style: kSmallMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Regulator onboarding placeholder — same vibe as the Vet page but for regulators.
class RegulatorPending extends StatelessWidget {
  const RegulatorPending({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Regulator — Next step', style: kAppBarTitle),
        backgroundColor: MyApp.agriGreen,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // header visual: saffron box + admin icon + description
              Row(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: MyApp.saffron.withAlpha(242), // keeps it subtle
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.admin_panel_settings_outlined,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Regulator onboarding', style: kTitle),
                        const SizedBox(height: 6),
                        Text(
                          'This mock shows what the regulator onboarding would include. The next step is not implemented here.',
                          style: kSubtitle,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // card showing fields that would be collected in real flow
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: const [
                      Text(
                        'What would be collected (mock):',
                        style: kCardHeading,
                      ),
                      SizedBox(height: 10),
                      Text('- Organization details & authorization'),
                      SizedBox(height: 6),
                      Text('- Contact person and official email/phone'),
                      SizedBox(height: 6),
                      Text('- Access scopes and data permissions (mock)'),
                      SizedBox(height: 6),
                      Text('- Regulatory region and proof of office'),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // notes card explaining this is a placeholder
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: const [
                      Text('Mock flow notes', style: kCardHeading),
                      SizedBox(height: 8),
                      Text(
                        '• Regulator accounts would be vetted and linked to organizations in a real system.\n'
                            '• In this mock the regulator page is intentionally a dead-end placeholder.\n'
                            '• No permission controls are available here.',
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // back button to go to login/register (same as vet)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: MyApp.agriGreen,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => const LoginRegisterScreen(),
                    ),
                  );
                },
                child: Text(
                  'Back to Login / Register',
                  style: kButtonText.copyWith(color: Colors.white),
                ),
              ),

              const SizedBox(height: 10),

              Text(
                'Note: This is a mock. Regulator onboarding not implemented.',
                textAlign: TextAlign.center,
                style: kSmallMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Profile page — simple mock profile for a farmer.
// I added casual comments everywhere so it's clear what's what.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  // Dummy/fake profile data used by the mock
  static const String name = 'Ramesh Kumar';
  static const String phone = '+91 9876543210';
  static const String linkedEmail = 'ramesh.k@example.com'; // show NA if none
  static const String location = 'Village: Kharat, District: Pune, MH';
  static const String aadhaar = 'XXXX-XXXX-1234';

  @override
  Widget build(BuildContext context) {
    final Color agriGreen = MyApp.agriGreen;
    // slightly stronger subtitle so text reads okay on cards
    final TextStyle subtitleStrong = kSubtitle.copyWith(
      color: Colors.black87,
      fontSize: 14,
    );
    final Color iconColor = Colors.black54;

    // tiny helper to make rows less repetitive
    Widget row(IconData icon, Widget content) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(width: 10),
          Expanded(child: content),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile', style: kAppBarTitle),
        backgroundColor: agriGreen,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Back',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.language, color: Colors.white),
            tooltip: 'Language',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const LanguageSelector()),
              );
            },
          ),
          const SizedBox(width: 6),
        ],
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header: avatar + name
              Card(
                color: kContainerBg,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14.0,
                    vertical: 16.0,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: MyApp.saffron.withAlpha(242),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 36,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: kTitle.copyWith(color: kContainerText),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Farmer profile',
                              style: kSubtitle.copyWith(color: kContainerText),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        tooltip: 'Edit profile (mock)',
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                  'Edit profile not implemented in mock',
                                ), duration: Duration(seconds: 2)
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Contact card: phone (tappable - copy), linked email
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 1,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('Contact', style: kCardHeading),
                      const SizedBox(height: 6),
                      SizedBox(
                        height: 40,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Icon(Icons.phone, size: 16),
                            const SizedBox(width: 10),
                            Expanded(child: SelectableText(phone, style: kSubtitle)),
                            IconButton(
                              padding: const EdgeInsets.all(6),
                              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                              icon: const Icon(Icons.copy_outlined, size: 18),
                              tooltip: 'Copy phone',
                              onPressed: () {
                                Clipboard.setData(const ClipboardData(text: '+91 9876543210'));
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Phone copied to clipboard')));
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      SizedBox(
                        height: 40,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Icon(Icons.email, size: 16),
                            const SizedBox(width: 10),
                            Expanded(child: SelectableText(linkedEmail, style: kSubtitle)),
                            IconButton(
                              padding: const EdgeInsets.all(6),
                              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                              icon: const Icon(Icons.copy_outlined, size: 18),
                              tooltip: 'Copy email',
                              onPressed: () {
                                Clipboard.setData(const ClipboardData(text: linkedEmail));
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Email copied to clipboard')));
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Location card
              // --- Location card (replace existing Location Card) ---
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 1,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('Location', style: kCardHeading),
                      const SizedBox(height: 12),
                      InkWell(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Google Maps redirect — Not implemented')));
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Row(
                          children: [
                            const Icon(Icons.location_on, size: 18),
                            const SizedBox(width: 12),
                            Expanded(child: Text(location, style: kSubtitle)),
                            const SizedBox(width: 8),
                            const Icon(Icons.chevron_right, color: Colors.black45),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // --- Identity card (replace existing Identity Card) ---
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 1,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('Identity', style: kCardHeading),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 44,
                        child: Row(
                          children: [
                            const Icon(Icons.badge_outlined, size: 18),
                            const SizedBox(width: 10),
                            Expanded(child: Text('Aadhaar: $aadhaar', style: kSubtitle)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              // Logout button — clear stack and go to login/register
              ElevatedButton(
                onPressed: () {
                  // Remove all previous routes so login becomes the single root.
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (_) => const LoginRegisterScreen(),
                    ),
                        (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: agriGreen),
                child: Text(
                  'Logout',
                  style: kButtonText.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Badge page (mock) — shows a default Bronze badge + plain, useful copy.
// Kept comments chill and clear.
class BadgePage extends StatelessWidget {
  const BadgePage({super.key});

  @override
  Widget build(BuildContext context) {
    final Color agriGreen = MyApp.agriGreen;
    final Color saffron = MyApp.saffron;
    final TextStyle small = kSubtitle.copyWith(
      color: Colors.black87,
      fontSize: 13,
    );
    final TextStyle muted = kSmallMuted;

    return Scaffold(
      appBar: AppBar(
        title: Text('Badge', style: kAppBarTitle),
        backgroundColor: agriGreen,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          // compact vertical layout to fit most screens without scrolling
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // hero row with bronze icon
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14.0,
                    vertical: 12.0,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: const Color(0xFFCD7F32), // bronze background
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.emoji_events,
                            color: Colors.white,
                            size: 36,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('Bronze badge', style: kTitle),
                            SizedBox(height: 4),
                            Text(
                              'Maintained since Jan 15, 2025',
                              style: kSubtitle,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // single compact card with clear copy about badges (mock)
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 1,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('Summary', style: kCardHeading),
                      const SizedBox(height: 8),
                      Text(
                        'Badges (Bronze / Silver / Gold) are shown as an illustrative mock to encourage app use. Actual benefits or programs would be determined by third-party or government schemes.',
                        style: kSubtitle,
                      ),

                      const SizedBox(height: 10),

                      // Benefits (short)
                      Text(
                        'Illustrative benefits',
                        style: kCardHeading.copyWith(fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      _CompactBullet(
                        'Greater buyer confidence in listings.',
                        style: small,
                      ),
                      _CompactBullet(
                        'Potential priority in pilot programs or promotions.',
                        style: small,
                      ),

                      const SizedBox(height: 10),

                      // How to keep it (practical)
                      Text(
                        'Recommended practices',
                        style: kCardHeading.copyWith(fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      _CompactBullet(
                        'Log medicines and treatments promptly.',
                        style: small,
                      ),
                      _CompactBullet(
                        'Observe withdrawal periods before offering products for sale.',
                        style: small,
                      ),
                      _CompactBullet(
                        'Respond to critical alerts and follow recommended actions.',
                        style: small,
                      ),

                      const SizedBox(height: 10),

                      // Risks (explicit, include lab tests)
                      Text(
                        'Risk of badge loss',
                        style: kCardHeading.copyWith(fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      _CompactBullet(
                        'Repeated withdrawal or safety violations.',
                        style: small,
                      ),
                      _CompactBullet(
                        'Failing required laboratory tests on sold products.',
                        style: small,
                      ),
                      _CompactBullet(
                        'Providing false or unverifiable records or repeatedly ignoring critical alerts.',
                        style: small,
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              // footer reminder that this is just a UI mock
              Text(
                'Note: This is a UI mock. Any real benefits, programs, eligibility rules, or verification processes are managed by external partners and public authorities.',
                style: muted,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// compact bullet (tight spacing and small text) — small helper widget
class _CompactBullet extends StatelessWidget {
  final String text;
  final TextStyle? style;
  const _CompactBullet(this.text, {this.style});

  @override
  Widget build(BuildContext context) {
    final TextStyle effective = style ?? kSubtitle;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: effective),
          Expanded(child: Text(text, style: effective)),
        ],
      ),
    );
  }
}

// Alerts page — lists critical alerts, field tests, and advisory notes.
// Comments are casual and the UI logic is unchanged.
class AlertsPage extends StatelessWidget {
  const AlertsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final Color agriGreen = MyApp.agriGreen;

    // text styles tuned for readability
    final TextStyle headingStyle = kCardHeading;
    final TextStyle titleStyle = kSubtitle.copyWith(color: Colors.black87);
    final TextStyle bodyStyle = kSubtitle.copyWith(color: Colors.black87, fontSize: 14);
    final TextStyle readableMuted = kSmallMuted.copyWith(color: Colors.black87.withOpacity(0.85));

    // color palette for the cards
    const Color palePink = Color(0xFFFFF0F2);
    const Color lightPink = Color(0xFFFFE8EB);
    const Color darkReadableRed = Color(0xFFD32F2F); // darker red for primary critical alert
    const Color actionListPink = Color(0xFFFFCDD2); // for AMU missed list
    const Color neutralGrey = Color(0xFFF5F5F5);

    // main critical card (darker red)
    Widget _primaryFieldTestCard({
      required String title,
      required String detail,
      required String impactNote,
      VoidCallback? onTap,
    }) {
      return Card(
        color: darkReadableRed,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 6,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: kTitle.copyWith(color: Colors.white)),
                const SizedBox(height: 8),
                Text(detail, style: bodyStyle.copyWith(color: Colors.white.withOpacity(0.95))),
                const SizedBox(height: 10),
                Text(impactNote, style: readableMuted.copyWith(color: Colors.white.withOpacity(0.95), fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ),
      );
    }

    // lighter field test card (clickable mock)
    Widget _fieldTestCard({
      required String title,
      required String detail,
      VoidCallback? onTap,
    }) {
      return Card(
        color: palePink,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap ??
                  () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('View lab report — Not implemented(Mock)'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 14.0),
            title: Text(title, style: titleStyle),
            subtitle: Text(detail, style: readableMuted),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('View lab report', style: titleStyle.copyWith(color: MyApp.agriGreen, fontWeight: FontWeight.w600)),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right, color: Colors.black54),
              ],
            ),
          ),
        ),
      );
    }

    // small pink action list tile (missed AMU, etc)
    Widget _actionListTile(String title, String subtitle, {VoidCallback? onTap}) {
      return Card(
        color: actionListPink,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 0,
        child: ListTile(
          onTap: onTap,
          title: Text(title, style: titleStyle.copyWith(fontWeight: FontWeight.w600)),
          subtitle: Text(subtitle, style: readableMuted),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        ),
      );
    }

    // plain grey alert tile for less urgent items
    Widget _plainAlertTile(String title, String subtitle, {VoidCallback? onTap}) {
      return Card(
        color: neutralGrey,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 0,
        child: ListTile(
          onTap: onTap,
          title: Text(title, style: titleStyle),
          subtitle: Text(subtitle, style: readableMuted),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Alerts', style: kAppBarTitle),
        backgroundColor: agriGreen,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Back',
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Heading for critical alerts
              Text('Critical Alerts', style: headingStyle),
              const SizedBox(height: 10),

              // Topmost — primary failed lab test (darker red, more readable)
              _primaryFieldTestCard(
                title: 'Failed Lab Test — Milk Sample',
                detail:
                'Laboratory analysis of a recent milk consignment detected an antibiotic MRL (Maximum Residue Limit) exceedance for a regulated compound. Product affected: milk.',
                impactNote:
                'Regulatory non-compliance identified. Immediate investigation and corrective actions are required. Continued non-compliance may affect certifications and program badges.',
              ),
              const SizedBox(height: 12),

              Text('Related Laboratory Findings', style: headingStyle.copyWith(fontSize: 16)),
              const SizedBox(height: 8),
              _fieldTestCard(
                title: 'Lab Test — Milk Sample (A2)',
                detail: 'Trace MRL exceedance detected in a secondary sample. Review batch records.',
              ),
              const SizedBox(height: 16),

              Text('Advisory Notes', style: headingStyle),
              const SizedBox(height: 8),
              _actionListTile(
                'Hen 2 — AMU Logging was Missed',
                'AMU entry for Hen 2 was not recorded. Please make sure future AMU records are logged on time to keep your records complete.',
                onTap: null,
              ),
              const SizedBox(height: 8),
              _actionListTile(
                'Cow 2 — AMU Logging was Missed',
                'AMU entry for Cow 2 was missed earlier. Ensure AMU records are logged consistently going forward to maintain accurate compliance history.',
                onTap: null,
              ),
              const SizedBox(height: 16),
              // Other alerts — neutral grey and more subdued text
              Text('Other Alerts', style: headingStyle),
              const SizedBox(height: 8),
              _plainAlertTile(
                'Random Audit Scheduled',
                'An audit is scheduled for 20 September 2025. Prepare requested records.',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Audit details (mock)'), duration: Duration(seconds: 2)));
                },
              ),

              const SizedBox(height: 18),
            ],
          ),
        ),
      ),
    );
  }
}

// HomeMock — main farmer home screen (UI mock).
// I added casual, obvious comments everywhere so a normal dude reading it gets it.
// No logic changes, only comments and tiny clarifying notes.
class HomeMock extends StatefulWidget {
  const HomeMock({super.key});

  @override
  State<HomeMock> createState() => _HomeMockState();
}

class _HomeMockState extends State<HomeMock> {
  bool _loading = false;
  String? _error;

  // Auto-scrolling banners (simulate endless rightward scroll by a large initial page)
  late PageController _bannerController;
  Timer? _bannerTimer;
  bool _bannerAnimating = false;
  final int _bannerInitialMultiplier = 1000; // large offset so we can scroll "right" indefinitely

  // simple banner data — just titles for the mock
  final List<Map<String, String>> _bannersData = [
    {'title': 'Failed Lab Report — Milk Sample'},
    {'title': 'Missed AMU Logging'},
    {'title': 'Audit Planned'},
  ];

  @override
  void initState() {
    super.initState();
    // tiny safe set to warm up state after build, no-op here
    WidgetsBinding.instance.addPostFrameCallback((_) => _safeSet(() {}));
    // create controller with a large initial page so we always animate to the right
    final int initialPage = _bannersData.length * _bannerInitialMultiplier;
    _bannerController = PageController(initialPage: initialPage, viewportFraction: 1.0);
    _startBannerAutoScroll();
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerController.dispose();
    super.dispose();
  }

  // helper that only calls setState if the widget is still mounted
  void _safeSet(VoidCallback fn) {
    if (mounted) setState(fn);
  }

  // mock refresh — keeps UI snappy but doesn't fetch real data
  Future<void> _refresh() async {
    _safeSet(() {
      _loading = true;
      _error = null;
    });
    try {
      // Keep refresh minimal — real data loaders should be inserted here
      await Future<void>.delayed(const Duration(milliseconds: 250));
    } catch (e) {
      _safeSet(() {
        _error = e.toString();
      });
    } finally {
      _safeSet(() {
        _loading = false;
      });
    }
  }

  void _startBannerAutoScroll() {
    _bannerTimer?.cancel();
    const Duration interval = Duration(seconds: 3);
    const Duration animDuration = Duration(milliseconds: 700);

    _bannerTimer = Timer.periodic(interval, (timer) async {
      if (!_bannerController.hasClients || _bannersData.isEmpty) return;
      if (_bannerAnimating) return; // guard against overlapping animations

      final double pageDouble = _bannerController.page ?? _bannerController.initialPage.toDouble();
      final int currentPage = pageDouble.round();
      final int nextPage = currentPage + 1; // always go right

      _bannerAnimating = true;
      try {
        await _bannerController.animateToPage(
          nextPage,
          duration: animDuration,
          curve: Curves.easeInOut,
        );
      } finally {
        _bannerAnimating = false;
      }
    });
  }

  // build the auto-scrolling banners — each banner is tappable and opens AlertsPage
  Widget _buildAutoScrollBanners(BuildContext context) {
    const Color bannerBg = Color(0xFFFFCDD2); // consistent light red used elsewhere
    final double height = 72; // match summary card height
    final int len = _bannersData.length;

    return SizedBox(
      height: height,
      child: PageView.builder(
        controller: _bannerController,
        physics: const NeverScrollableScrollPhysics(),
        padEnds: false,
        itemBuilder: (context, index) {
          final item = _bannersData[index % len];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 6.0),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AlertsPage()));
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                decoration: BoxDecoration(
                  color: bannerBg,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        item['title'] ?? '',
                        style: kSubtitle.copyWith(
                          color: Colors.black87,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.chevron_right, color: Colors.black54, size: 20),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Helper to build compact summary card — generic so it can be reused
  Widget _summaryCard({
    required BuildContext context,
    required String title,
    required String value,
    double? height,
    Color? accentColor, // optional semantic color
    VoidCallback? onTap, // optional tap handler
  }) {
    final double h = (height != null && height > 0) ? height : 72.0;

    final Color bg = accentColor != null
        ? accentColor.withOpacity(0.14)
        : Theme.of(context).cardColor;

    final Color border = accentColor != null
        ? accentColor.withOpacity(0.20)
        : Colors.transparent;

    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: h, maxHeight: h),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: border, width: accentColor != null ? 1.0 : 0.0),
          ),
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Center(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Left: title (left-aligned)
                  Expanded(
                    flex: 6,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        title,
                        style: kSmallMuted.copyWith(color: Colors.black87, fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),

                  const Spacer(flex: 1),

                  // Right: numeric value (right-aligned, visually prominent)
                  Expanded(
                    flex: 3,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          value,
                          style: kTitle.copyWith(fontSize: 18, color: Colors.black87),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Full-width action tile used for main actions on the home screen
  Widget _actionTileFull({
    required BuildContext context,
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final Color agriGreen = MyApp.agriGreen;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        height: 72,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: agriGreen,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.white, size: 26),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(label, style: kTitle.copyWith(fontSize: 16)),
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right, size: 22, color: Colors.black26),
          ],
        ),
      ),
    );
  }

  // Defensive aggregator: reads module-level collections but uses safe defaults
  Map<String, dynamic> _computeTotals() {
    final List<_Group> groups =
    (_LivestockManagementPageState._groups is List<_Group>) ? _LivestockManagementPageState._groups : <_Group>[];

    final Set<String> withdrawalSet =
    (_LivestockManagementPageState._animalsOnMedicine is Set<String>) ? _LivestockManagementPageState._animalsOnMedicine : <String>{};

    final Map<String, List<_Animal>> customAnimals =
    (_LivestockManagementPageState._customAnimals is Map<String, List<_Animal>>)
        ? _LivestockManagementPageState._customAnimals
        : <String, List<_Animal>>{};

    final int totalAnimals = groups.fold<int>(0, (s, g) => s + ((g.count >= 0) ? g.count : 0));
    final int totalYoungFromGroups = groups.fold<int>(0, (s, g) => s + ((g.young >= 0) ? g.young : 0));
    final int totalYoungFromCustom = customAnimals.values.fold<int>(0, (s, list) => s + list.where((a) => a.young == true).length);
    final int totalYoung = totalYoungFromGroups + totalYoungFromCustom;

    final int totalPregnantFromGroups = groups.fold<int>(0, (s, g) => s + ((g.pregnant >= 0) ? g.pregnant : 0));
    final int totalPregnantFromCustom = customAnimals.values.fold<int>(0, (s, list) => s + list.where((a) => a.pregnant == true).length);
    final int totalPregnant = totalPregnantFromGroups + totalPregnantFromCustom;

    final Set<String> mergedWithdrawal = Set<String>.from(withdrawalSet);
    for (final list in customAnimals.values) {
      for (final a in list) {
        if (a.inWithdrawal == true) mergedWithdrawal.add(a.id);
      }
    }
    final int totalWithdrawal = mergedWithdrawal.length;

    return <String, dynamic>{
      'totalAnimals': totalAnimals,
      'totalYoung': totalYoung,
      'totalPregnant': totalPregnant,
      'totalWithdrawal': totalWithdrawal,
    };
  }

  @override
  Widget build(BuildContext context) {
    try {
      final Color agriGreen = MyApp.agriGreen;
      final totals = _computeTotals();

      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: Padding(
            padding: const EdgeInsets.only(left: 12.0),
            child: Center(
              child: SizedBox(
                width: 45,
                height: 45,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(9),
                  child: Image.asset('lib/images/logo.png', fit: BoxFit.cover, width: 36, height: 36),
                ),
              ),
            ),
          ),
          title: Text('Nirmay — Farmer', style: kAppBarTitle),
          backgroundColor: agriGreen,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.emoji_events_outlined),
              tooltip: 'Badges',
              onPressed: () async {
                await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const BadgePage()));
                if (mounted) setState(() {});
              },
            ),
            const SizedBox(width: 6),
            Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: Center(
                child: GestureDetector(
                  onTap: () async {
                    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProfilePage()));
                    if (mounted) setState(() {});
                  },
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, color: MyApp.agriGreen, size: 22),
                  ),
                ),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: _refresh,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // compact summary grid — two rows of summary cards
                  SizedBox(
                    height: 72, // overall compact row height
                    child: Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: _summaryCard(
                              context: context,
                              title: 'Total Animals',
                              value: '${totals['totalAnimals']}',
                              height: 64,
                              accentColor: const Color(0xFF9E9E9E), // neutral grey
                              onTap: () async {
                                await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LivestockManagementPage()));
                                if (mounted) setState(() {});
                              },
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: _summaryCard(
                              context: context,
                              title: 'Young',
                              value: '${totals['totalYoung']}',
                              height: 64,
                              accentColor: const Color(0xFF6BA9F8), // dull blue
                              onTap: () async {
                                await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LivestockManagementPage()));
                                if (mounted) setState(() {});
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 72,
                    child: Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: _summaryCard(
                              context: context,
                              title: 'Pregnant',
                              value: '${totals['totalPregnant']}',
                              height: 64,
                              accentColor: const Color(0xFFFFD54D), // dull yellow
                              onTap: () async {
                                await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LivestockManagementPage()));
                                if (mounted) setState(() {});
                              },
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: _summaryCard(
                              context: context,
                              title: 'On Medicine',
                              value: '${totals['totalWithdrawal']}',
                              height: 64,
                              accentColor: const Color(0xFFE57373), // faded light red
                              onTap: () async {
                                await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const WithdrawalListPage()));
                                if (mounted) setState(() {});
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text('Priority Alerts', style: kCardHeading),
                  const SizedBox(height: 12),
                  _buildAutoScrollBanners(context),
                  const SizedBox(height: 18),
                  _actionTileFull(
                    context: context,
                    label: 'Livestock Management',
                    icon: Icons.manage_accounts,
                    onTap: () async {
                      await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LivestockManagementPage()));
                      if (mounted) setState(() {});
                    },
                  ),
                  const SizedBox(height: 12),
                  _actionTileFull(
                    context: context,
                    label: 'Animals on Medicine',
                    icon: Icons.local_pharmacy,
                    onTap: () async {
                      await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const WithdrawalListPage()));
                      if (mounted) setState(() {});
                    },
                  ),
                  const SizedBox(height: 12),
                  _actionTileFull(
                    context: context,
                    label: 'Alerts',
                    icon: Icons.notifications_active,
                    onTap: () async {
                      await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AlertsPage()));
                      if (mounted) setState(() {});
                    },
                  ),
                  const SizedBox(height: 12),
                  _actionTileFull(
                    context: context,
                    label: 'Contact Vet',
                    icon: Icons.phone_in_talk,
                    onTap: () async {
                      await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ContactVetPage()));
                      if (mounted) setState(() {});
                    },
                  ),
                  const SizedBox(height: 24),
                  if (_loading)
                    const Center(child: Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator())),
                  if (_error != null)
                    Card(
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: Colors.red),
                            const SizedBox(width: 8),
                            Expanded(child: Text(_error!, style: kSmallMuted)),
                            TextButton(onPressed: _refresh, child: const Text('Retry')),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    } catch (e, st) {
      // fallback UI if something goes kaboom — helpful for debugging in the mock
      return Scaffold(
        appBar: AppBar(
          title: Text('Nirmay — Farmer', style: kAppBarTitle),
          backgroundColor: MyApp.agriGreen,
          elevation: 0,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              children: [
                Card(
                  color: Colors.white,
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text('Something went wrong rendering the home screen', style: kTitle.copyWith(fontSize: 16)),
                        const SizedBox(height: 8),
                        Text('Error: ${e.runtimeType}', style: kSubtitle),
                        const SizedBox(height: 12),
                        Text(
                          'Tap Retry to attempt a rebuild. If the issue persists, check debug console for stack details.',
                          style: kSmallMuted,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => setState(() {}),
                                child: const Text('Retry'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: SingleChildScrollView(
                    child: Text(
                      st.toString(),
                      style: const TextStyle(fontSize: 11),
                      maxLines: 40,
                      overflow: TextOverflow.fade,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
}

// Simple model used inside this app (now serializable)
class _Group {
  final String id;
  final String name;
  final String type;
  int count;
  int pregnant;
  int young;

  _Group({
    required this.id,
    required this.name,
    required this.type,
    required this.count,
    this.pregnant = 0,
    this.young = 0,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': type,
    'count': count,
    'pregnant': pregnant,
    'young': young,
  };

  factory _Group.fromJson(Map<String, dynamic> j) => _Group(
    id: j['id'] as String,
    name: j['name'] as String,
    type: j['type'] as String,
    count: (j['count'] as num).toInt(),
    pregnant: (j['pregnant'] as num).toInt(),
    young: (j['young'] as num).toInt(),
  );
}

// Persist groups globally if feature flag is on. In this mock errors are ignored.
Future<void> _saveGroupsGlobal() async {
  if (!kEnableGroupPersistence) return;
  try {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(_LivestockManagementPageState._groups
        .map((g) => g.toJson())
        .toList());
    await prefs.setString('agri_groups_v1', encoded);
  } catch (_) {
    // ignore save error in mock
  }
}

// Livestock management screen — lets you view/create groups and see simple stats.
// Comments are chill and casual — no logic changes, just more docs so a normal dude gets it.
class LivestockManagementPage extends StatefulWidget {
  const LivestockManagementPage({super.key});

  @override
  State<LivestockManagementPage> createState() =>
      _LivestockManagementPageState();
}

class _LivestockManagementPageState extends State<LivestockManagementPage> {
  final TextEditingController _searchController = TextEditingController();

  // manual AMU records map (groupId -> list of manual records)
  // paste this next to _animalsOnMedicine and _customAnimals
  static final Map<String, List<Map<String, String>>> _manualAmuRecords = {};
  // Only two types in this mock — keep it tiny and predictable
  static const List<String> _types = ['Cow', 'Hen'];

  // Dummy initial data (non-final so it can be replaced when loading)
  // These are easy-to-recognize groups used by the rest of the mock.
  static List<_Group> _groups = [
    _Group(
      id: 'g1',
      name: 'Milkers A',
      type: 'Cow',
      count: 4,
      pregnant: 3,
      young: 1,
    ),
    _Group(
      id: 'g2',
      name: 'Backyard Hens',
      type: 'Hen',
      count: 8,
      pregnant: 0,
      young: 3,
    ),
  ];

  // Prototype: set of animal IDs that are currently 'on medicine' (withdrawal)
  // Animal id format used by the group/animal generator is: '${g.id}_a${i+1}'
  // Pre-populated with the two animals you wanted (cow 2 and hen 2).
  static final Set<String> _animalsOnMedicine = {
    'g1_a2', // cow 2 in group g1
    'g2_a2', // hen 2 in group g2
  };

  // Runtime storage for user-created animals (per-group). Keeps created animals
  // persistent across navigation during the mock session.
  static final Map<String, List<_Animal>> _customAnimals = {};

  // runtime set of removed/generated animal IDs (per-group)
  static final Map<String, Set<String>> _removedAnimals = {};

  // UI filter state — 'All' | 'Cow' | 'Hen'
  String _filterType = 'All';

  @override
  void initState() {
    super.initState();
    // load from prefs only if persistence is toggled on
    if (kEnableGroupPersistence) {
      _loadGroups();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ---------- Persistence helpers (use only when kEnableGroupPersistence == true) ----------
  Future<void> _loadGroups() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('agri_groups_v1');
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw) as List;
        _groups = decoded
            .map((e) => _Group.fromJson(e as Map<String, dynamic>))
            .toList();
        if (mounted) setState(() {});
      }
    } catch (_) {
      // ignore — keep defaults in the mock
    }
  }

  // << replace lines 2185–2194 with this >>
  static Future<void> _saveGroups() async {
    await _saveGroupsGlobal();
  }

  // computed filtered list based on search text + type chip
  List<_Group> get _filtered {
    final q = _searchController.text.trim().toLowerCase();
    return _groups.where((g) {
      final matchesType = _filterType == 'All' ? true : g.type == _filterType;
      final matchesQuery = q.isEmpty ? true : g.name.toLowerCase().contains(q);
      return matchesType && matchesQuery;
    }).toList();
  }

  // bottom sheet to create a new group — small friendly UI with a shake on error
  void _openAddGroupDialog() {
    final nameController = TextEditingController();
    String selectedType = _types.first;
    bool showError = false;
    double shakeOffset = 0.0;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return SafeArea(
          top: false,
          bottom: true,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 12,
              bottom:
              MediaQuery.of(ctx).viewInsets.bottom +
                  MediaQuery.of(ctx).padding.bottom +
                  16,
            ),
            child: StatefulBuilder(
              builder: (context, setModalState) {
                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: shakeOffset),
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  builder: (context, offset, child) {
                    return Transform.translate(
                      offset: Offset(offset, 0),
                      child: child,
                    );
                  },
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // small grabber
                        Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),

                        // centered title
                        Center(child: Text('Create Group', style: kTitle)),
                        const SizedBox(height: 12),

                        // name input (shows error border / text when empty on create)
                        TextFormField(
                          controller: nameController,
                          decoration: InputDecoration(
                            labelText: 'Group Name',
                            hintText: 'e.g. Milkers A',
                            errorText: showError ? 'Group name is required' : null,
                          ),
                          textCapitalization: TextCapitalization.words,
                          onChanged: (v) {
                            if (showError && v.trim().isNotEmpty) {
                              setModalState(() => showError = false);
                            }
                          },
                        ),
                        const SizedBox(height: 12),

                        // type selector
                        DropdownButtonFormField<String>(
                          initialValue: selectedType,
                          dropdownColor: Colors.white,
                          items: _types
                              .map(
                                (t) => DropdownMenuItem(value: t, child: Text(t)),
                          )
                              .toList(),
                          onChanged: (v) {
                            if (v != null) {
                              setModalState(() => selectedType = v);
                            }
                          },
                          decoration: const InputDecoration(labelText: 'Type'),
                        ),

                        const SizedBox(height: 18),

                        // actions (cancel / create)
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Navigator.of(ctx).pop(),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  child: Text('Cancel'),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  final name = nameController.text.trim();
                                  if (name.isEmpty) {
                                    // show error and trigger a short shake
                                    setModalState(() {
                                      showError = true;
                                      shakeOffset = 8.0;
                                    });
                                    Future.delayed(
                                      const Duration(milliseconds: 80),
                                          () {
                                        setModalState(() => shakeOffset = -8.0);
                                      },
                                    );
                                    Future.delayed(
                                      const Duration(milliseconds: 160),
                                          () {
                                        setModalState(() => shakeOffset = 0.0);
                                      },
                                    );
                                    return;
                                  }

                                  // create group (mock) and close sheet
                                  setState(() {
                                    _groups.insert(
                                      0,
                                      _Group(
                                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                                        name: name,
                                        type: selectedType,
                                        count: 0,
                                        pregnant: 0,
                                        young: 0,
                                      ),
                                    );
                                  });
                                  // persist only when persistence is enabled (toggle)
                                  if (kEnableGroupPersistence) {
                                    _saveGroups();
                                  }
                                  Navigator.of(ctx).pop();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: MyApp.agriGreen,
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  child: Text(
                                    'Create',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  // returns an emoji widget depending on the group type
  Widget _emojiForType(String type) {
    switch (type) {
      case 'Cow':
        return const Text('🐄', style: TextStyle(fontSize: 26));
      case 'Hen':
        return const Text('🐔', style: TextStyle(fontSize: 26));
      default:
        return const Icon(Icons.pets);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color agriGreen = MyApp.agriGreen;

    return Scaffold(
      appBar: AppBar(
        title: Text('Livestock Management', style: kAppBarTitle),
        backgroundColor: agriGreen,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.medication, color: Colors.white),
            tooltip: 'On medicine',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const WithdrawalListPage()),
              );
            },
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            children: [
              // Search field — filters groups by name
              TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: 'Search Groups',
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: agriGreen, width: 2),
                  ),
                  suffixIcon: _searchController.text.isEmpty
                      ? null
                      : IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {});
                    },
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Filter chips row (only Cow & Hen in this mock)
              Row(
                children: [
                  Text('Filter:', style: kCardHeading.copyWith(fontSize: 14)),
                  const SizedBox(width: 10),
                  FilterChip(
                    label: const Text('All'),
                    selected: _filterType == 'All',
                    onSelected: (_) => setState(() => _filterType = 'All'),
                    backgroundColor: Colors.grey.shade200,
                    selectedColor: MyApp.agriGreen,
                    checkmarkColor: Colors.white, // <- tick color white
                    labelStyle: TextStyle(
                      color: _filterType == 'All' ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                    selectedShadowColor: Colors.transparent,
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Cow'),
                    selected: _filterType == 'Cow',
                    onSelected: (_) => setState(() => _filterType = 'Cow'),
                    backgroundColor: Colors.grey.shade200,
                    selectedColor: MyApp.agriGreen,
                    checkmarkColor: Colors.white, // <- tick color white
                    labelStyle: TextStyle(
                      color: _filterType == 'Cow' ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                    selectedShadowColor: Colors.transparent,
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Hen'),
                    selected: _filterType == 'Hen',
                    onSelected: (_) => setState(() => _filterType = 'Hen'),
                    backgroundColor: Colors.grey.shade200,
                    selectedColor: MyApp.agriGreen,
                    checkmarkColor: Colors.white, // <- tick color white
                    labelStyle: TextStyle(
                      color: _filterType == 'Hen' ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                    selectedShadowColor: Colors.transparent,
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // List of groups (or empty state)
              Expanded(
                child: _filtered.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text('No groups found', style: kTitle),
                      SizedBox(height: 8),
                      Text(
                        'Tap the + button to add a group.',
                        style: kSubtitle,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
                    : ListView.separated(
                  padding: const EdgeInsets.only(
                    top: 8,
                    bottom: 96,
                    left: 4,
                    right: 4,
                  ),
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: _filtered.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final g = _filtered[index];
                    return Card(
                      // clean, white card — subtle shadow for elevation and clear separation
                      color: MyApp.containerBg,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(color: Colors.grey.shade200),
                      ),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 6.0,
                          horizontal: 4.0,
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          // neutral envelope for emoji (white with tiny shadow)
                          leading: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(8),
                                  blurRadius: 3,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Center(child: _emojiForType(g.type)),
                          ),
                          title: Text(
                            g.name,
                            style: kTitle.copyWith(
                              color: Colors.black87,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Text(
                            '${g.type}${(g.pregnant > 0 || g.young > 0) ? ' • Pregnant: ${g.pregnant} • Young: ${g.young}' : ''}',
                            style: kSubtitle.copyWith(
                              color: Colors.black54,
                              fontSize: 13,
                            ),
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: MyApp.agriGreen,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.03),
                                  blurRadius: 2,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Text(
                              '${g.count}',
                              style: kTitle.copyWith(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          onTap: () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => GroupDetailPage(group: g),
                              ),
                            );
                            if (mounted) setState(() {});
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: agriGreen,
        onPressed: _openAddGroupDialog,
        tooltip: 'Create group',
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

// Group detail page — shows generated + custom animals for a group.
// Comments are casual and everywhere so a normal dude can follow along.
// No logic changes, only added/expanded comments and small clarifying notes.

class GroupDetailPage extends StatefulWidget {
  final _Group group;
  const GroupDetailPage({required this.group, super.key});

  @override
  _GroupDetailPageState createState() => _GroupDetailPageState();
}

// Local animal model used by GroupDetailPage
// --- REPLACE ENTIRE _Animal CLASS WITH THIS (keeps serializable fields) ---
class _Animal {
  final String id;
  final String name;
  final String tag;
  final String type; // species type (e.g. 'Cow' / 'Hen')

  String? breed;
  String? gender;
  double? age; // years, fractional allowed (prototype)
  bool pashuAadharLinked;

  // these must be mutable because code sets them (mark dead, toggle)
  bool pregnant;
  bool young;
  bool dead;

  // new: whether animal is currently in withdrawal (prototype, persisted later)
  bool inWithdrawal;

  _Animal({
    required this.id,
    required this.name,
    required this.tag,
    required this.type,
    this.breed,
    this.gender,
    this.age,
    this.pashuAadharLinked = false,
    this.pregnant = false,
    this.young = false,
    this.dead = false,
    this.inWithdrawal = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'tag': tag,
    'type': type,
    'breed': breed,
    'gender': gender,
    'age': age,
    'pashuAadharLinked': pashuAadharLinked,
    'pregnant': pregnant,
    'young': young,
    'dead': dead,
    'inWithdrawal': inWithdrawal,
  };

  // simple fromJson for future use (not heavily used in mock)
  // ignore: unused_element
  factory _Animal.fromJson(Map<String, dynamic> j) {
    return _Animal(
      id: j['id'] as String? ?? '',
      name: j['name'] as String? ?? '',
      tag: j['tag'] as String? ?? '',
      type: j['type'] as String? ?? '',
      breed: j['breed'] as String?,
      gender: j['gender'] as String?,
      age: j['age'] is num ? (j['age'] as num).toDouble() : null,
      pashuAadharLinked: j['pashuAadharLinked'] as bool? ?? false,
      pregnant: j['pregnant'] as bool? ?? false,
      young: j['young'] as bool? ?? false,
      dead: j['dead'] as bool? ?? false,
      inWithdrawal: j['inWithdrawal'] as bool? ?? false,
    );
  }

  _Animal copyWith({
    String? id,
    String? name,
    String? tag,
    String? type,
    String? breed,
    String? gender,
    double? age,
    bool? pashuAadharLinked,
    bool? pregnant,
    bool? young,
    bool? dead,
    bool? inWithdrawal,
  }) {
    return _Animal(
      id: id ?? this.id,
      name: name ?? this.name,
      tag: tag ?? this.tag,
      type: type ?? this.type,
      breed: breed ?? this.breed,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      pashuAadharLinked: pashuAadharLinked ?? this.pashuAadharLinked,
      pregnant: pregnant ?? this.pregnant,
      young: young ?? this.young,
      dead: dead ?? this.dead,
      inWithdrawal: inWithdrawal ?? this.inWithdrawal,
    );
  }
}


class _GroupDetailPageState extends State<GroupDetailPage>
    with TickerProviderStateMixin {
  // made non-final so we can add new animals at runtime
  late List<_Animal> _animals;
  final TextEditingController _searchController = TextEditingController();

  // status filter (All / Pregnant / Young)
  String _filter = 'All';
  // additional filters
  String _breedFilter = 'All';
  String _genderFilter = 'All';

  // selection support for multi-select actions
  final Set<String> _selectedIds = {};

  bool get _isSelecting => _selectedIds.isNotEmpty;

  @override
  void initState() {
    super.initState();

    final g = widget.group;
    final total = g.count;

    // include any user-created animals for this group (added via the Add-animal dialog)
    final List<_Animal> customList = _LivestockManagementPageState._customAnimals[g.id] ?? <_Animal>[];
    final int customCount = customList.length;
    final int baseCount = (total - customCount) >= 0 ? (total - customCount) : total;

    // distribution numbers (used to assign pregnancy among generated animals)
    final int pn = g.pregnant.clamp(0, total);

    // generate prototype (base) animals — hardcoded for known groups, predictable fallback otherwise
    final List<_Animal> generated;
    if (g.id == 'g2') {
      // Backyard Hens — fixed, hardcoded 8 hens
      generated = [
        _Animal(id: 'g2_a1', name: 'Hen 1', tag: 'H101', type: 'Hen', breed: 'Rhode Island', gender: 'Female', age: 0.3, pashuAadharLinked: false, pregnant: false, young: true, dead: false, inWithdrawal: _LivestockManagementPageState._animalsOnMedicine.contains('g2_a1')),
        _Animal(id: 'g2_a2', name: 'Hen 2', tag: 'H102', type: 'Hen', breed: 'Desi', gender: 'Female', age: 0.8, pashuAadharLinked: false, pregnant: false, young: false, dead: false, inWithdrawal: _LivestockManagementPageState._animalsOnMedicine.contains('g2_a2')),
        _Animal(id: 'g2_a3', name: 'Hen 3', tag: 'H103', type: 'Hen', breed: 'Rhode Island', gender: 'Female', age: 1.3, pashuAadharLinked: false, pregnant: false, young: false, dead: false, inWithdrawal: _LivestockManagementPageState._animalsOnMedicine.contains('g2_a3')),
        _Animal(id: 'g2_a4', name: 'Hen 4', tag: 'H104', type: 'Hen', breed: 'Desi', gender: 'Female', age: 0.3, pashuAadharLinked: false, pregnant: false, young: true, dead: false, inWithdrawal: _LivestockManagementPageState._animalsOnMedicine.contains('g2_a4')),
        _Animal(id: 'g2_a5', name: 'Hen 5', tag: 'H105', type: 'Hen', breed: 'Rhode Island', gender: 'Female', age: 0.8, pashuAadharLinked: false, pregnant: false, young: false, dead: false, inWithdrawal: _LivestockManagementPageState._animalsOnMedicine.contains('g2_a5')),
        _Animal(id: 'g2_a6', name: 'Hen 6', tag: 'H106', type: 'Hen', breed: 'Desi', gender: 'Female', age: 1.3, pashuAadharLinked: false, pregnant: false, young: false, dead: false, inWithdrawal: _LivestockManagementPageState._animalsOnMedicine.contains('g2_a6')),
        _Animal(id: 'g2_a7', name: 'Hen 7', tag: 'H107', type: 'Hen', breed: 'Rhode Island', gender: 'Female', age: 0.3, pashuAadharLinked: false, pregnant: false, young: true, dead: false, inWithdrawal: _LivestockManagementPageState._animalsOnMedicine.contains('g2_a7')),
        _Animal(id: 'g2_a8', name: 'Hen 8', tag: 'H108', type: 'Hen', breed: 'Desi', gender: 'Female', age: 0.8, pashuAadharLinked: false, pregnant: false, young: false, dead: false, inWithdrawal: _LivestockManagementPageState._animalsOnMedicine.contains('g2_a8')),
      ];
    } else if (g.id == 'g1') {
      // Milkers A — fixed, hardcoded 4 cows
      generated = [
        _Animal(id: 'g1_a1', name: 'Cow 1', tag: 'C101', type: 'Cow', breed: 'Gir', gender: 'Female', age: 1.6, pashuAadharLinked: false, pregnant: true, young: false, dead: false, inWithdrawal: _LivestockManagementPageState._animalsOnMedicine.contains('g1_a1')),
        _Animal(id: 'g1_a2', name: 'Cow 2', tag: 'C102', type: 'Cow', breed: 'Sahiwal', gender: 'Female', age: 1.6, pashuAadharLinked: false, pregnant: true, young: false, dead: false, inWithdrawal: _LivestockManagementPageState._animalsOnMedicine.contains('g1_a2')),
        _Animal(id: 'g1_a3', name: 'Cow 3', tag: 'C103', type: 'Cow', breed: 'Tharparkar', gender: 'Female', age: 2.2, pashuAadharLinked: false, pregnant: true, young: false, dead: false, inWithdrawal: _LivestockManagementPageState._animalsOnMedicine.contains('g1_a3')),
        _Animal(id: 'g1_a4', name: 'Cow 4', tag: 'C104', type: 'Cow', breed: 'Gir', gender: 'Female', age: 1.0, pashuAadharLinked: false, pregnant: false, young: true, dead: false, inWithdrawal: _LivestockManagementPageState._animalsOnMedicine.contains('g1_a4')),
      ];
    } else {
      // predictable fallback generation (no randomness)
      generated = List<_Animal>.generate(
        baseCount,
            (i) {
          final lowerType = g.type.toLowerCase();
          double ageYears;
          if (lowerType == 'hen') {
            final int idx = i % 3;
            ageYears = 0.3 + idx * 0.5;
            if (ageYears > 1.5) ageYears = 1.5;
          } else if (lowerType == 'cow') {
            final int idx = i % 5;
            ageYears = 1.0 + idx * 0.6;
          } else {
            ageYears = 1.0 + (i % 6);
          }

          final String gender = (lowerType == 'cow' || lowerType == 'hen') ? 'Female' : ((i % 2 == 0) ? 'Female' : 'Male');

          final breed = g.type == 'Cow' ? (['Gir', 'Sahiwal', 'Tharparkar'][i % 3]) : (['Rhode Island', 'Desi'][i % 2]);

          final bool isYoung = lowerType == 'cow' ? ageYears < 2.0 : (lowerType == 'hen' ? ageYears < 0.5 : ageYears < 2.0);

          final id = '${g.id}_a${i + 1}';
          final bool inWithdrawal = _LivestockManagementPageState._animalsOnMedicine.contains(id);

          return _Animal(
            id: id,
            name: '${g.type} ${i + 1}',
            tag: '${g.type.substring(0, 1).toUpperCase()}${100 + i + 1}',
            type: g.type,
            breed: breed,
            gender: gender,
            age: double.parse(ageYears.toStringAsFixed(1)),
            pashuAadharLinked: (i % 5 == 0),
            pregnant: false,
            young: isYoung,
            dead: false,
            inWithdrawal: inWithdrawal,
          );
        },
      );
    }
    // filter out any generated animals that were previously removed
    final removedForGroup = _LivestockManagementPageState._removedAnimals[widget.group.id];
    if (removedForGroup != null && removedForGroup.isNotEmpty) {
      generated.removeWhere((a) => removedForGroup.contains(a.id));
    }

    // final list shown in the page: hardcoded/generated base animals followed by any custom animals
    _animals = [...generated, ...customList];

    // assign pregnancy to exactly pn eligible generated animals (do not overwrite custom animals)
    int toAssignPreg = pn;
    for (int i = 0; i < _animals.length && toAssignPreg > 0; i++) {
      final a = _animals[i];
      final lt = a.type.toLowerCase();

      // skip custom animals (they have unique ids not matching generated pattern)
      final bool isCustom = customList.any((c) => c.id == a.id);
      if (isCustom) continue;

      if (!a.young && lt == 'cow' && (a.gender ?? '').toLowerCase() == 'female') {
        a.pregnant = true;
        toAssignPreg--;
      }
    }

    // ensure young are never pregnant
    for (var a in _animals) {
      if (a.young) a.pregnant = false;
    }

    // Enforce exact counts on the group object so header tiles match the list
    g.pregnant = _animals.where((a) => a.pregnant).length;
    g.young = _animals.where((a) => a.young).length;

    // Rebuild list when search text changes
    _searchController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // combined list: generated animals + per-group custom animals (so newly created animals appear immediately)
  List<_Animal> get _allAnimals {
    return _animals;
  }

  List<_Animal> get _filtered {
    final q = _searchController.text.trim().toLowerCase();
    return _allAnimals.where((a) {
      // never show dead animals in the list
      if (a.dead) return false;

      final matchesQuery = q.isEmpty ||
          a.name.toLowerCase().contains(q) ||
          a.tag.toLowerCase().contains(q) ||
          (a.breed ?? '').toLowerCase().contains(q);

      final matchesStatus = (_filter == 'All')
          ? true
          : (_filter == 'Pregnant'
          ? a.pregnant
          : _filter == 'Young'
          ? a.young
          : true);

      final matchesBreed = (_breedFilter == 'All')
          ? true
          : (a.breed == _breedFilter);

      final matchesGender = (_genderFilter == 'All')
          ? true
          : (a.gender == _genderFilter);

      return matchesQuery && matchesStatus && matchesBreed && matchesGender;
    }).toList();
  }

  int get _totalVisible => _allAnimals.where((a) => !a.dead).length;
  int get _pregnantVisible =>
      _allAnimals.where((a) => a.pregnant && !a.dead).length;
  int get _youngVisible => _allAnimals.where((a) => a.young && !a.dead).length;

  // emoji helper used by GroupDetailPage
  Widget _emojiForType(String type) {
    switch (type) {
      case 'Cow':
        return const Text('🐄', style: TextStyle(fontSize: 22));
      case 'Hen':
        return const Text('🐔', style: TextStyle(fontSize: 22));
      default:
        return const Icon(Icons.pets);
    }
  }

  void _toggleSelect(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedIds.clear();
    });
  }

  // ---- REPLACED _showMarkDeadDialog (selection-aware, removes animals safely) ----
  Future<void> _showMarkDeadDialog() async {
    if (_selectedIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No animals selected'), duration: Duration(seconds: 2),),
      );
      return;
    }

    final selectedAnimals = _animals.where((a) => _selectedIds.contains(a.id)).toList(growable: false);
    final idsSnapshot = _selectedIds.toList(growable: false);

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _MarkDeadDialog(selectedAnimals: selectedAnimals, ids: idsSnapshot),
    );

    if (result != null && result['ids'] is List && mounted) {
      final List ids = List.from(result['ids'] as List);
      final reason = (result['reason'] ?? '').toString();

      setState(() {
        // remove selected animals from the local list and any per-group custom list so IDs/names remain stable
        for (final idRaw in ids) {
          final idStr = idRaw.toString();
          bool removedSomething = false;

          // try to remove from the combined runtime animals list first
          final int idx = _animals.indexWhere((a) => a.id == idStr);
          if (idx != -1) {
            final removed = _animals.removeAt(idx);
            removedSomething = true;

            // update group counters exactly once per removed animal
            if (widget.group.count > 0) widget.group.count--;
            if (removed.pregnant && widget.group.pregnant > 0) widget.group.pregnant--;
            if (removed.young && widget.group.young > 0) widget.group.young--;
          }

          // also try removing from per-group custom list (idempotent)
          final customList = _LivestockManagementPageState._customAnimals[widget.group.id];
          if (customList != null) {
            final int cIdx = customList.indexWhere((c) => c.id == idStr);
            if (cIdx != -1) {
              final removed = customList.removeAt(cIdx);
              if (customList.isEmpty) {
                _LivestockManagementPageState._customAnimals.remove(widget.group.id);
              }

              // only decrement counters here if we didn't already remove above
              if (!removedSomething) {
                removedSomething = true;
                if (widget.group.count > 0) widget.group.count--;
                if (removed.pregnant && widget.group.pregnant > 0) widget.group.pregnant--;
                if (removed.young && widget.group.young > 0) widget.group.young--;
              }
            }
          }

          // if we successfully removed a generated animal, record it so generator won't recreate it
          if (removedSomething && idStr.startsWith('${widget.group.id}_a')) {
            final set = _LivestockManagementPageState._removedAnimals
                .putIfAbsent(widget.group.id, () => <String>{});
            set.add(idStr);
          }
        }
      });

      final bool isCow = (widget.group.type.toLowerCase() == 'cow');
      final String animalLabel = isCow
          ? (ids.length == 1 ? 'cow' : 'cows')
          : (ids.length == 1 ? 'hen' : 'hens');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Marked ${ids.length} $animalLabel deceased'), duration: const Duration(seconds: 3)),
      );

      // ensure selection mode exits after marking dead
      _clearSelection();

      if (kEnableGroupPersistence) _saveGroupsGlobal();
    }
  }

  Future<void> _showSellDialog() async {
    // If nothing selected, quick message and return.
    if (_selectedIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No animals selected'), duration: Duration(seconds: 2),),
      );
      return;
    }

    // snapshot selected animals / ids for the dialog (immutable for safety)
    final selectedAnimals = _animals
        .where((a) => _selectedIds.contains(a.id))
        .toList(growable: false);
    final idsSnapshot = _selectedIds.toList(growable: false);

    Map<String, dynamic>? result;
    try {
      result = await showDialog<Map<String, dynamic>>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => _SellDialog(
          selectedAnimals: selectedAnimals,
          ids: idsSnapshot,
          groupType: widget.group.type,
        ),
      );
    } catch (e, st) {
      debugPrint('showSellDialog failed: $e\n$st');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to open sell dialog: $e'), duration: const Duration(seconds: 2)),
        );
      }
      result = null;
    }

    // Apply sale result — do not change counts; clear selection and notify user
    if (result != null && result['ids'] is List) {
      final List ids = List.from(result['ids'] as List);
      final seller = (result['seller'] ?? '').toString();
      final qty = (result['quantity'] ?? '').toString();
      final price = (result['price'] ?? '').toString();

      setState(() {
        // keep animals/group counts unchanged by design
        _selectedIds.removeAll(ids.map((e) => e.toString()));
      });

      if (mounted) {
        final bool isCow = (widget.group.type.toLowerCase() == 'cow');
        final String unit = isCow ? 'litres' : 'unit(s)';
        final String animal = isCow ? (ids.length == 1 ? 'cow' : 'cows') : (ids.length == 1 ? 'hen' : 'hens');

        final String message = 'Sold $qty $unit @ ₹$price — $animal';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), duration: const Duration(seconds: 3)),
        );
      }
    }
  }

  // --- Add animal dialog & creation (small bottom-sheet form) ---
  Future<void> _openAddAnimalDialog() async {
    final g = widget.group;
    final nameCtrl = TextEditingController();
    final tagCtrl = TextEditingController();
    String breed = (g.type == 'Cow')
        ? 'Gir'
        : ((g.type == 'Hen') ? 'Rhode Island' : 'Unknown');
    String gender = (g.type == 'Cow' || g.type == 'Hen') ? 'Female' : 'Female';
    bool pregnant = false;
    bool young = false;
    String ageStr = '';
    bool _attemptedSubmit = false;
    double shakeOffset = 0.0;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        final double bottomInset =
            MediaQuery.of(ctx).viewInsets.bottom + MediaQuery.of(ctx).padding.bottom;
        return SafeArea(
            top: false,
            bottom: true,
            child: Padding(
              padding: EdgeInsets.only(bottom: bottomInset),
              child: StatefulBuilder(builder: (ctx2, setSt) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  transform: Matrix4.translationValues(shakeOffset, 0, 0),
                  curve: Curves.easeOut,
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('Add ${g.type}', style: kCardHeading),
                      const SizedBox(height: 12),

                      // Name (required + shake + red)
                      TextField(
                        controller: nameCtrl,
                        decoration: InputDecoration(
                          labelText: 'Name',
                          errorText: _attemptedSubmit && nameCtrl.text.trim().isEmpty ? 'Required' : null,
                        ),
                        onChanged: (_) => setSt(() {}),
                      ),
                      const SizedBox(height: 8),

                      // Tag (required + shake + red)
                      TextField(
                        controller: tagCtrl,
                        decoration: InputDecoration(
                          labelText: 'Tag',
                          errorText: _attemptedSubmit && tagCtrl.text.trim().isEmpty ? 'Required' : null,
                        ),
                        onChanged: (_) => setSt(() {}),
                      ),
                      const SizedBox(height: 8),

                      DropdownButtonFormField<String>(
                        value: breed,
                        items: (g.type == 'Cow'
                            ? ['Gir', 'Sahiwal', 'Tharparkar']
                            : ['Rhode Island', 'Desi'])
                            .map((b) => DropdownMenuItem(
                          value: b,
                          child: Text(b),
                        ))
                            .toList(),
                        onChanged: (v) {
                          if (v != null) setSt(() => breed = v);
                        },
                        decoration: const InputDecoration(labelText: 'Breed'),
                      ),
                      const SizedBox(height: 8),

                      // gender: disabled for Cow/Hen (unchangeable); interactive for others
                      if (!(g.type == 'Cow' || g.type == 'Hen'))
                        DropdownButtonFormField<String>(
                          value: gender,
                          items: ['Female', 'Male']
                              .map((v) => DropdownMenuItem(
                            value: v,
                            child: Text(v),
                          ))
                              .toList(),
                          onChanged: (v) {
                            if (v != null) setSt(() => gender = v);
                          },
                          decoration: const InputDecoration(labelText: 'Gender'),
                        )
                      else
                        Padding(
                          padding: const EdgeInsets.only(top: 6.0, bottom: 6.0),
                          child: InputDecorator(
                            decoration: const InputDecoration(labelText: 'Gender (fixed)'),
                            child: Text('Female', style: kSubtitle),
                          ),
                        ),

                      const SizedBox(height: 8),

                      // Age input: numeric-only (no words) + inline error
                      TextField(
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                          LengthLimitingTextInputFormatter(5),
                        ],
                        decoration: InputDecoration(
                          labelText: 'Age (years, e.g. 1.2)',
                          errorText: _attemptedSubmit && (ageStr.trim().isEmpty || (double.tryParse(ageStr) ?? 0) <= 0)
                              ? 'Enter valid age'
                              : null,
                        ),
                        onChanged: (v) => setSt(() => ageStr = v),
                      ),
                      const SizedBox(height: 8),

                      // determine if the entered age classifies the animal as "young"
                      Builder(builder: (ctx3) {
                        final double parsed = double.tryParse(ageStr) ?? 0.0;
                        final bool ageValid = parsed > 0.0;
                        final bool isAgeYoung = (g.type == 'Hen')
                            ? (parsed > 0 && parsed < 0.5) // < 6 months -> young
                            : (g.type == 'Cow' ? (parsed > 0 && parsed < 2.0) : false);

                        // allow pregnancy toggle only when:
                        //  - a valid age has been entered (ageValid)
                        //  - the animal is NOT classified as young (isAgeYoung == false)
                        final bool canTogglePregnant = ageValid && !isAgeYoung && (g.type == 'Cow' || g.type != 'Cow');

                        return Column(
                          children: [
                            CheckboxListTile(
                              value: pregnant,
                              onChanged: canTogglePregnant
                                  ? (v) => setSt(() {
                                // only allow pregnancy when age is valid and not young
                                pregnant = (v ?? false) && !isAgeYoung;
                                if (pregnant) young = false;
                              })
                                  : null,
                              title: const Text('Pregnant'),
                              controlAffinity: ListTileControlAffinity.leading,
                            ),

                            // Young: read-only badge (auto-assigned from age)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6.0),
                              child: Row(
                                children: [
                                  Text('Young:', style: kSubtitle),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isAgeYoung ? Colors.blueGrey.shade100 : Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(isAgeYoung ? 'Yes' : 'No', style: const TextStyle(fontSize: 12)),
                                  ),
                                ],
                              ),
                            ),

                            // Helpful hint: if age invalid, show short guidance; if young, show the existing hint.
                            if (!ageValid)
                              Padding(
                                padding: const EdgeInsets.only(top: 6.0),
                                child: Text(
                                  'Enter age to enable pregnancy option',
                                  style: kSmallMuted,
                                ),
                              )
                            else if (isAgeYoung)
                              Padding(
                                padding: const EdgeInsets.only(top: 6.0),
                                child: Text(
                                  'Age indicates young — pregnancy option disabled',
                                  style: kSmallMuted,
                                ),
                              ),
                          ],
                        );
                      }),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                final name = nameCtrl.text.trim();
                                final tag = tagCtrl.text.trim();
                                final parsedAge = double.tryParse(ageStr);
                                final bool ageValid = (parsedAge != null && parsedAge > 0);

                                if (name.isEmpty || tag.isEmpty || !ageValid) {
                                  // mark attempt so fields show red errors, vibrate and animate a short shake
                                  setSt(() {
                                    _attemptedSubmit = true;
                                    shakeOffset = 8.0;
                                  });
                                  HapticFeedback.mediumImpact();
                                  Future.delayed(const Duration(milliseconds: 80), () {
                                    setSt(() => shakeOffset = -8.0);
                                  });
                                  Future.delayed(const Duration(milliseconds: 160), () {
                                    setSt(() => shakeOffset = 0.0);
                                  });
                                  return;
                                }

                                final double ageVal = parsedAge!;

                                // compute 'young' automatically from age (no user toggle)
                                final bool computedYoung = (g.type == 'Hen')
                                    ? (ageVal > 0 && ageVal < 0.5) // hen < 6 months => young
                                    : (g.type == 'Cow' ? (ageVal > 0 && ageVal < 2.0) : false);

                                // if computed young, ensure pregnant is false
                                final bool finalPregnant = computedYoung ? false : pregnant;

                                final newId =
                                    '${g.id}_a${_animals.length + 1}'; // simple id
                                final _Animal newAnimal = _Animal(
                                  id: newId,
                                  name: name,
                                  tag: tag,
                                  type: g.type,
                                  breed: breed,
                                  gender: (g.type == 'Cow' || g.type == 'Hen')
                                      ? 'Female'
                                      : gender,
                                  age: ageVal,
                                  pashuAadharLinked: false,
                                  pregnant: finalPregnant,
                                  young: computedYoung,
                                  dead: false,
                                  inWithdrawal: false,
                                );

                                // push into custom list for this group so it survives navigation
                                setState(() {
                                  final list = _LivestockManagementPageState._customAnimals.putIfAbsent(g.id, () => <_Animal>[]);
                                  list.add(newAnimal);
                                  _animals.add(newAnimal);

                                  // update local page counters immediately
                                  widget.group.count = widget.group.count + 1;
                                  if (newAnimal.pregnant) widget.group.pregnant = widget.group.pregnant + 1;
                                  if (newAnimal.young) widget.group.young = widget.group.young + 1;
                                  // ALSO update the same group object in the global groups list so Home header reflects the change
                                  final int gi = _LivestockManagementPageState._groups.indexWhere((g) => g.id == widget.group.id);
                                  if (gi != -1) {
                                    _LivestockManagementPageState._groups[gi].count = widget.group.count;
                                    _LivestockManagementPageState._groups[gi].pregnant = widget.group.pregnant;
                                    _LivestockManagementPageState._groups[gi].young = widget.group.young;
                                  }
                                });

                                // optional persistence hook that exists elsewhere in the file
                                if (kEnableGroupPersistence) _saveGroupsGlobal();

                                // close the sheet and immediately open the profile for the created animal
                                Navigator.of(ctx).pop();
                                // small delay ensures the modal has dismissed cleanly before pushing
                                Future.microtask(() {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(builder: (_) => AnimalProfilePage(animal: newAnimal)),
                                  );
                                });
                              },
                              child: const Text('Add animal'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                );
              }),
            )
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color agriGreen = MyApp.agriGreen;
    final g = widget.group;

    return PopScope(
        canPop: !_isSelecting,
        onPopInvokedWithResult: (didPop, result) {
          if (_isSelecting) {
            // exit selection mode instead of popping
            _clearSelection();
          }
        },
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: agriGreen,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                _isSelecting ? Icons.close : Icons.arrow_back,
                color: Colors.white,
              ),
              onPressed: () {
                if (_isSelecting) {
                  _clearSelection();
                  return;
                }
                Navigator.of(context).pop();
              },
            ),
            title: Text(
              _isSelecting ? '${_selectedIds.length} selected' : g.name,
              style: kAppBarTitle,
            ),
          ),
          body: Column(
            children: [
              Container(
                width: double.infinity,
                color: MyApp.containerBg,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total: $_totalVisible', style: kTitle),
                    Text('Pregnant: $_pregnantVisible', style: kSubtitle),
                    Text('Young: $_youngVisible', style: kSubtitle),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 8.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Search field (live search)
                    TextField(
                      controller: _searchController,
                      onChanged: (_) {
                        if (mounted) setState(() {});
                      },
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search),
                        hintText: 'Search by Name / Tag / Breed',
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        suffixIcon: _searchController.text.isEmpty
                            ? null
                            : IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            if (mounted) setState(() {});
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Horizontal filters: status, breed, gender
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.only(top: 6, bottom: 2),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Filter:',
                            style: kCardHeading.copyWith(fontSize: 14),
                          ),
                          const SizedBox(width: 10),

                          // STATUS CHIPS
                          FilterChip(
                            label: const Text('All'),
                            selected: _filter == 'All',
                            onSelected: (_) => setState(() {
                              _filter = 'All';
                            }),
                            backgroundColor: Colors.grey.shade200,
                            selectedColor: MyApp.agriGreen,
                            checkmarkColor: Colors.white,
                            labelStyle: TextStyle(
                              color: _filter == 'All'
                                  ? Colors.white
                                  : Colors.black87,
                              fontWeight: FontWeight.w600,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          const SizedBox(width: 8),
                          FilterChip(
                            label: const Text('Pregnant'),
                            selected: _filter == 'Pregnant',
                            onSelected: (_) => setState(() {
                              _filter = 'Pregnant';
                            }),
                            backgroundColor: Colors.grey.shade200,
                            selectedColor: MyApp.agriGreen,
                            checkmarkColor: Colors.white,
                            labelStyle: TextStyle(
                              color: _filter == 'Pregnant'
                                  ? Colors.white
                                  : Colors.black87,
                              fontWeight: FontWeight.w600,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          const SizedBox(width: 8),
                          FilterChip(
                            label: const Text('Young'),
                            selected: _filter == 'Young',
                            onSelected: (_) => setState(() {
                              _filter = 'Young';
                            }),
                            backgroundColor: Colors.grey.shade200,
                            selectedColor: MyApp.agriGreen,
                            checkmarkColor: Colors.white,
                            labelStyle: TextStyle(
                              color: _filter == 'Young'
                                  ? Colors.white
                                  : Colors.black87,
                              fontWeight: FontWeight.w600,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),

                          const SizedBox(width: 12),

                          // BREED CHIPS derived from group type (toggle breed without changing status)
                          ...((widget.group.type == 'Cow'
                              ? ['Gir', 'Sahiwal', 'Tharparkar']
                              : ['Rhode Island', 'Desi'])
                              .map(
                                (b) => Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: FilterChip(
                                label: Text(b),
                                selected: _breedFilter == b,
                                onSelected: (_) => setState(() {
                                  _breedFilter = (_breedFilter == b)
                                      ? 'All'
                                      : b;
                                }),
                                backgroundColor: Colors.grey.shade200,
                                selectedColor: MyApp.agriGreen,
                                checkmarkColor: Colors.white,
                                labelStyle: TextStyle(
                                  color: _breedFilter == b
                                      ? Colors.white
                                      : Colors.black87,
                                  fontWeight: FontWeight.w600,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 0,
                              ),
                            ),
                          )),

                          const SizedBox(width: 8),

                          // GENDER CHIPS (hidden for Cow/Hen since they are female)
                          if (!(widget.group.type == 'Cow' ||
                              widget.group.type == 'Hen')) ...[
                            FilterChip(
                              label: const Text('Female'),
                              selected: _genderFilter == 'Female',
                              onSelected: (_) => setState(() {
                                _genderFilter = _genderFilter == 'Female'
                                    ? 'All'
                                    : 'Female';
                              }),
                              backgroundColor: Colors.grey.shade200,
                              selectedColor: MyApp.agriGreen,
                              checkmarkColor: Colors.white,
                              labelStyle: TextStyle(
                                color: _genderFilter == 'Female'
                                    ? Colors.white
                                    : Colors.black87,
                                fontWeight: FontWeight.w600,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
                            ),
                            const SizedBox(width: 8),
                            FilterChip(
                              label: const Text('Male'),
                              selected: _genderFilter == 'Male',
                              onSelected: (_) => setState(() {
                                _genderFilter = _genderFilter == 'Male'
                                    ? 'All'
                                    : 'Male';
                              }),
                              backgroundColor: Colors.grey.shade200,
                              selectedColor: MyApp.agriGreen,
                              checkmarkColor: Colors.white,
                              labelStyle: TextStyle(
                                color: _genderFilter == 'Male'
                                    ? Colors.white
                                    : Colors.black87,
                                fontWeight: FontWeight.w600,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: _filtered.isEmpty
                    ? Center(
                  child: Text(
                    _isSelecting
                        ? 'No matching animals'
                        : 'No animals found',
                    style: kSubtitle,
                  ),
                )
                    : ListView.builder(
                  itemCount: _filtered.length,
                  itemBuilder: (ctx, idx) {
                    final a = _filtered[idx];
                    final selected = _selectedIds.contains(a.id);

                    final BorderSide tileBorder = selected
                        ? BorderSide(color: MyApp.agriGreen, width: 1.4)
                        : BorderSide(color: Colors.grey.shade200, width: 1);

                    return Card(
                        color: MyApp.containerBg,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: tileBorder,
                        ),
                        elevation: selected ? 4 : 2,
                        child: InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onLongPress: () => _toggleSelect(a.id),
                            onTap: () async {
                              if (_isSelecting) {
                                _toggleSelect(a.id);
                                return;
                              }
                              await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => AnimalProfilePage(animal: a),
                                ),
                              );

                              // refresh inWithdrawal flags from the global set so the list shows newly-logged AMU
                              if (mounted) {
                                setState(() {
                                  for (final ani in _animals) {
                                    ani.inWithdrawal = _LivestockManagementPageState._animalsOnMedicine.contains(ani.id);
                                  }
                                });
                              }
                            },
                            child: Row(
                                children: [
                                  // subtle left accent bar when selected (clean, not full-card tint)
                                  Container(
                                    width: 6,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      color: selected ? MyApp.agriGreen : Colors.transparent,
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(10),
                                        bottomLeft: Radius.circular(10),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 6.0,
                                          horizontal: 8.0,
                                        ),
                                        child: ListTile(
                                          // slightly taller when on medicine so chip fits comfortably
                                            contentPadding: EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: a.inWithdrawal ? 12 : 8,
                                            ),
                                            // smaller check avatar when selected — less dominant
                                            leading: selected
                                                ? CircleAvatar(
                                              radius: 18,
                                              backgroundColor: MyApp.agriGreen,
                                              child: const Icon(Icons.check, color: Colors.white, size: 16),
                                            )
                                                : Container(
                                              width: 44,
                                              height: 44,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(10),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black.withAlpha(8),
                                                    blurRadius: 3,
                                                    offset: const Offset(0, 1),
                                                  ),
                                                ],
                                              ),
                                              child: Center(child: _emojiForType(a.type)),
                                            ),
                                            title: Text(
                                              a.name,
                                              style: kTitle.copyWith(
                                                color: selected ? MyApp.agriGreen : Colors.black87,
                                                fontSize: 16,
                                              ),
                                            ),
                                            subtitle: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                if ((a.breed ?? '').isNotEmpty ||
                                                    (a.gender ?? '').isNotEmpty ||
                                                    (a.age ?? 0) > 0)
                                                  Padding(
                                                    padding: const EdgeInsets.only(top: 4.0),
                                                    child: Text(
                                                      '${a.breed ?? ''}${(a.breed != null && a.gender != null) ? ' • ' : ''}${a.gender ?? ''}${(a.age != null && a.age! > 0) ? ' • ${a.age} yrs' : ''}',
                                                      style: kSubtitle.copyWith(
                                                        color: selected ? MyApp.agriGreen.withOpacity(0.8) : Colors.black54,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ),
                                                if (a.inWithdrawal)
                                                  Padding(
                                                    padding: const EdgeInsets.only(top: 6.0),
                                                    child: Text(
                                                      'On Medicine until Cleared',
                                                      style: kSubtitle.copyWith(
                                                        color: selected ? MyApp.agriGreen : Colors.red.shade700,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                            trailing: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment: CrossAxisAlignment.end,
                                              children: [
                                                if (a.inWithdrawal)
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: selected ? MyApp.agriGreen.withOpacity(0.12) : Colors.red.shade100,
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    child: Text(
                                                      'On Medicine',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: selected ? MyApp.agriGreen : Colors.red.shade800,
                                                      ),
                                                    ),
                                                  ),
                                                if (a.pregnant)
                                                  Padding(
                                                    padding: const EdgeInsets.only(top: 6.0),
                                                    child: Container(
                                                      padding: const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 4,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color: MyApp.saffron.withAlpha(200),
                                                        borderRadius: BorderRadius.circular(8),
                                                      ),
                                                      child: const Text(
                                                        'Pregnant',
                                                        style: TextStyle(fontSize: 12),
                                                      ),
                                                    ),
                                                  ),
                                                if (a.young)
                                                  Padding(
                                                    padding: const EdgeInsets.only(top: 6.0),
                                                    child: Container(
                                                      padding: const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 4,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color: MyApp.containerBg,
                                                        borderRadius: BorderRadius.circular(8),
                                                      ),
                                                      child: const Text(
                                                        'Young',
                                                        style: TextStyle(fontSize: 12),
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),

                                            onLongPress: () {
                                              // start selection
                                              _toggleSelect(a.id);
                                            },
                                            onTap: () async {
                                              if (_isSelecting) {
                                                _toggleSelect(a.id);
                                                return;
                                              }
                                              // Open animal profile page
                                              await Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: (_) => AnimalProfilePage(animal: a),
                                                ),
                                              );

                                              // refresh inWithdrawal flags from the global set so the list shows newly-logged AMU
                                              if (mounted) {
                                                setState(() {
                                                  for (final ani in _animals) {
                                                    ani.inWithdrawal = _LivestockManagementPageState._animalsOnMedicine.contains(ani.id);
                                                  }
                                                });
                                              }

                                            }),
                                      )
                                  )
                                ]
                            )
                        )
                    );
                  },
                ),
              ),
            ],
          ),
          floatingActionButton: _isSelecting
              ? Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FloatingActionButton(
                heroTag: 'sell_btn',
                backgroundColor: MyApp.agriGreen,
                onPressed: _showSellDialog,
                tooltip: 'Sell Products',
                child: const Icon(Icons.currency_rupee, color: Colors.white),
              ),
              const SizedBox(height: 10),
              FloatingActionButton(
                heroTag: 'mark_dead',
                backgroundColor: const Color(0xFFCC3B2D),
                onPressed: _showMarkDeadDialog,
                tooltip: 'Mark deceased',
                child: const Text(
                  '💀',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          )
              : FloatingActionButton(
            heroTag: 'add_animal',
            backgroundColor: MyApp.agriGreen,
            onPressed: _openAddAnimalDialog,
            tooltip: 'Add animal',
            child: const Icon(Icons.add, color: Colors.white),
          ),
        )
    );
  }
}

// AMU log dialog + Animal profile UI
// Comments are chill and casual — no logic changes, just extra doc-comments so a regular dude can follow.

Future<bool?> openAmuLogDialog(BuildContext context, {String? initialAnimalId}) async {
  // quick helpers / config (two meds per cow4/hen4) — small hardcoded map for the mock
  final medMap = <String, List<String>>{
    'g1_a4': ['Med-Cow-A', 'Med-Cow-B'],
    'g2_a4': ['Med-Hen-A', 'Med-Hen-B'],
  };

  // more info for meds: unit/means/min/max for simple validation and hints
  final medInfo = <String, Map<String, String>>{
    'Med-Cow-A': {'means': 'Injection', 'unit': 'ml', 'min': '1', 'max': '10'},
    'Med-Cow-B': {'means': 'Injection', 'unit': 'mg/kg', 'min': '0.05', 'max': '0.5'},
    'Med-Hen-A': {'means': 'Oral', 'unit': 'ml', 'min': '0.5', 'max': '2.0'},
    'Med-Hen-B': {'means': 'Spray', 'unit': 'ml', 'min': '0.2', 'max': '1.0'},
  };

  // build a list of selectable animals from groups (group.name • type • #index)
  final animalOptions = <Map<String, String>>[];
  for (final g in _LivestockManagementPageState._groups) {
    for (var i = 0; i < g.count; i++) {
      animalOptions.add({
        'id': '${g.id}_a${i + 1}',
        'label': '${g.name} • ${g.type} • #${i + 1}',
        'type': g.type,
      });
    }
  }

  // if no animals exist, quick message and return false
  if (animalOptions.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('No Animals Available'),
      duration: Duration(seconds: 2),
    ));
    return false;
  }

  // show the dialog — returns true when a record is added
  final bool? _dialogResult = await showDialog<bool?>(
    context: context,
    barrierDismissible: false,
    builder: (dlgCtx) {
      // local dialog state (kept inside builder)
      String selectedAnimalId = initialAnimalId ?? animalOptions.first['id']!;
      String? selectedMed;
      String doseStr = '';
      String daysStr = '';
      String timesStr = '';
      bool attempted = false; // used to flip validation errors on submit
      double shake = 0.0; // small shake animation when invalid submit
      bool doseOutOfRange = false;
      String? doseRangeHint;

      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        content: SingleChildScrollView(
          child: StatefulBuilder(
            builder: (sbCtx, setDlgState) {
              final mq = MediaQuery.of(sbCtx);
              final double maxHeight = mq.size.height * 0.80;
              final double dialogWidth = mq.size.width * 0.88;

              final availableMeds = medMap[selectedAnimalId] ?? [];
              final medsEnabled = availableMeds.isNotEmpty;
              final fieldsEnabled = selectedMed != null;

              final unit = selectedMed != null ? (medInfo[selectedMed]?['unit'] ?? '') : '';
              final means = selectedMed != null ? (medInfo[selectedMed]?['means'] ?? '') : '';

              // Validate inputs and save a simple manual record (in-memory)
              void validateAndSave() {
                final doseVal = double.tryParse(doseStr);
                final daysVal = int.tryParse(daysStr);
                final timesVal = int.tryParse(timesStr);

                final doseOk = doseVal != null;
                final daysOk = daysVal != null && daysVal > 0;
                final timesOk = timesVal != null && timesVal > 0;
                final medOk = selectedMed != null;

                if (!medOk || !doseOk || !daysOk || !timesOk) {
                  setDlgState(() {
                    attempted = true;
                    shake = 8.0;
                  });
                  HapticFeedback.mediumImpact();
                  Future.delayed(const Duration(milliseconds: 80), () => setDlgState(() => shake = -8.0));
                  Future.delayed(const Duration(milliseconds: 160), () => setDlgState(() => shake = 0.0));
                  return;
                }

                // dosage range warning (still accepts but not blocked)
                final info = medInfo[selectedMed!]!;
                final min = double.tryParse(info['min'] ?? '');
                final max = double.tryParse(info['max'] ?? '');
                if ((min != null && doseVal! < min) || (max != null && doseVal! > max)) {
                  ScaffoldMessenger.of(dlgCtx).showSnackBar(const SnackBar(
                    content: Text('Dosage outside permitted limits'),
                    duration: Duration(seconds: 3),
                  ));
                }

                // store manual record (simple keys used by AnimalProfilePage)
                final record = <String, String>{
                  'date': DateTime.now().toIso8601String().split('T').first,
                  'drug': selectedMed!,
                  'dose': '$doseStr $unit',
                  'means': means,
                  'days': daysStr,
                  'times_per_day': timesStr,
                  'freq_list': '',
                  'completed_list': '',
                  'missed_list': '',
                  'withdrawal_days': '7',
                  'requires_followup': 'true',
                  'note': 'Incomplete',
                };

                // add to in-memory manual records and mark animal as 'on medicine'
                _LivestockManagementPageState._manualAmuRecords
                    .putIfAbsent(selectedAnimalId, () => <Map<String, String>>[])
                    .add(record);
                _LivestockManagementPageState._animalsOnMedicine.add(selectedAnimalId);

                // close dialog and show confirmation
                Navigator.of(dlgCtx).pop(true);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('AMU Logged'),
                  duration: Duration(seconds: 3),
                ));
              }

              return Padding(
                padding: EdgeInsets.only(bottom: mq.viewInsets.bottom),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: maxHeight),
                  child: SizedBox(
                    width: dialogWidth,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      transform: Matrix4.translationValues(shake, 0, 0),
                      padding: const EdgeInsets.all(16.0),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text('Log AMU', style: kCardHeading),
                            const SizedBox(height: 12),

                            // date (read-only) — rendered as text (simple)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Date', style: kSmallMuted),
                                  const SizedBox(height: 6),
                                  Text(DateTime.now().toIso8601String().split('T').first,
                                      style: kTitle.copyWith(fontSize: 18)),
                                ],
                              ),
                            ),

                            // animal selector: hide when dialog opened from an animal profile (initialAnimalId != null)
                            if (initialAnimalId == null) ...[
                              DropdownButtonFormField<String>(
                                value: selectedAnimalId,
                                items: animalOptions
                                    .map((a) => DropdownMenuItem(value: a['id'], child: Text(a['label']!)))
                                    .toList(),
                                onChanged: (v) => setDlgState(() {
                                  selectedAnimalId = v!;
                                  selectedMed = null;
                                  doseStr = '';
                                  daysStr = '';
                                  timesStr = '';
                                  attempted = false;
                                }),
                                decoration: const InputDecoration(labelText: 'Select animal'),
                              ),
                              const SizedBox(height: 8),
                            ] else
                              const SizedBox(height: 8),

                            // med selector (enabled only when that animal has meds)
                            DropdownButtonFormField<String>(
                              value: selectedMed,
                              decoration: InputDecoration(
                                labelText: 'Medicine',
                                errorText: attempted && selectedMed == null ? 'Required' : null,
                              ),
                              items: availableMeds.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                              onChanged: medsEnabled
                                  ? (v) => setDlgState(() {
                                selectedMed = v;
                                doseStr = '';
                                doseOutOfRange = false;
                                doseRangeHint = null;
                              })
                                  : null,
                            ),

                            const SizedBox(height: 8),

                            // means/unit (read-only)
                            InputDecorator(
                              decoration: const InputDecoration(labelText: 'Means'),
                              child: Text(selectedMed != null ? '${medInfo[selectedMed]!['means']}' : '-'),
                            ),

                            const SizedBox(height: 8),

                            // Dose input (number)
                            TextField(
                              enabled: fieldsEnabled,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                              decoration: InputDecoration(
                                labelText: 'Dose',
                                suffixText: selectedMed != null ? (medInfo[selectedMed]!['unit']) : '',
                                errorText: attempted && doseStr.trim().isEmpty ? 'Required' : null,
                              ),
                              onChanged: (v) => setDlgState(() {
                                doseStr = v;
                                // live dosage check (warning only)
                                if (selectedMed != null && medInfo[selectedMed] != null) {
                                  final info = medInfo[selectedMed]!;
                                  final min = double.tryParse(info['min'] ?? '');
                                  final max = double.tryParse(info['max'] ?? '');
                                  final val = double.tryParse(v);
                                  if (val != null && ((min != null && val < min) || (max != null && val > max))) {
                                    doseOutOfRange = true;
                                    doseRangeHint = 'Valid: ${min ?? '-'} - ${max ?? '-'} ${info['unit'] ?? ''}';
                                  } else {
                                    doseOutOfRange = false;
                                    doseRangeHint = null;
                                  }
                                } else {
                                  doseOutOfRange = false;
                                  doseRangeHint = null;
                                }
                              }),
                            ),

                            const SizedBox(height: 8),
                            if (doseOutOfRange)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Text(
                                  'Dosage outside recommended range — ${doseRangeHint ?? ''}',
                                  style: kSubtitle.copyWith(color: Colors.red, fontWeight: FontWeight.w700),
                                ),
                              ),

                            // frequency per day
                            DropdownButtonFormField<String>(
                              value: timesStr.isNotEmpty ? timesStr : null,
                              decoration: InputDecoration(
                                labelText: 'Frequency per day',
                                errorText: attempted && timesStr.trim().isEmpty ? 'Required' : null,
                              ),
                              items: ['1', '2', '3', '4'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                              onChanged: fieldsEnabled ? (v) => setDlgState(() => timesStr = v ?? '') : null,
                            ),

                            const SizedBox(height: 8),

                            // number of days
                            DropdownButtonFormField<String>(
                              value: daysStr.isNotEmpty ? daysStr : null,
                              decoration: InputDecoration(
                                labelText: 'Number of days',
                                errorText: attempted && daysStr.trim().isEmpty ? 'Required' : null,
                              ),
                              items: ['1', '2', '3', '5', '7', '10', '14'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                              onChanged: fieldsEnabled ? (v) => setDlgState(() => daysStr = v ?? '') : null,
                            ),

                            const SizedBox(height: 12),

                            // view prescription (mock)
                            OutlinedButton(onPressed: null, child: const Text('View prescription (mock)')),

                            const SizedBox(height: 12),

                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () => Navigator.of(dlgCtx).pop(false),
                                    child: const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Text('Cancel')),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: validateAndSave,
                                    child: const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Text('Add Log')),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );
    },
  );
  return _dialogResult;
}


/// Animal profile page — opened from GroupDetailPage when an animal is tapped.
/// This includes a simple mock of AMU logs that are deterministic for the demo.
class AnimalProfilePage extends StatelessWidget {
  final _Animal animal;
  const AnimalProfilePage({required this.animal, super.key});

  // tiny helper: gender emoji
  Widget _genderEmoji(String? gender) {
    final g = (gender ?? '').toLowerCase();
    if (g.contains('female')) return const Text('♀️', style: TextStyle(fontSize: 20));
    if (g.contains('male')) return const Text('♂️', style: TextStyle(fontSize: 20));
    return const Text('⚧', style: TextStyle(fontSize: 20));
  }

  // helper: emoji by type
  Widget _typeEmoji(String type) {
    switch (type.toLowerCase()) {
      case 'cow':
        return const Text('🐄', style: TextStyle(fontSize: 36));
      case 'hen':
        return const Text('🐔', style: TextStyle(fontSize: 36));
      default:
        return const Icon(Icons.pets, size: 36);
    }
  }

  // Build a deterministic list of mock AMU logs.
  // Rules:
  // - cows/hens with ids ending in 1 or 3 OR animals present in _animalsOnMedicine have logs
  // - manual records added via the AMU dialog are prepended if present
  List<Map<String, String>> _mockAmuLogs() {
    final t = (animal.type ?? '').toLowerCase();
    final idEnds = animal.id.toLowerCase();
    final bool isCow = t.contains('cow');
    final bool isHen = t.contains('hen') || t.contains('chicken');
    final bool isOnMedicine = _LivestockManagementPageState._animalsOnMedicine.contains(animal.id);
    final bool hasLogs = (isCow || isHen) && (isOnMedicine || idEnds.endsWith('1') || idEnds.endsWith('3'));

    // if manual records exist, return them first (they are authoritative)
    final manual = _LivestockManagementPageState._manualAmuRecords[animal.id];
    if (manual != null && manual.isNotEmpty) {
      final manualCopy = manual.map((m) => Map<String, String>.from(m)).toList();
      return manualCopy;
    }

    if (!hasLogs) return [];

    final bool isThird = idEnds.endsWith('3');
    final bool isSecond = idEnds.endsWith('2');

    // Prototype "today" so mock behavior is stable
    final DateTime _mockToday = DateTime(2025, 9, 15);

    // helper: expand frequency tokens
    List<String> _expandFreqList(int days, int timesPerDay) {
      final List<String> out = [];
      for (var d = 1; d <= days; d++) {
        if (timesPerDay <= 1) {
          out.add('Day $d');
        } else {
          for (var t = 1; t <= timesPerDay; t++) {
            out.add('Day $d • Dose $t');
          }
        }
      }
      return out;
    }

    // Compute completion/missed/incomplete using start date, days, times per day.
    Map<String, String> _computeStatus(String startDateStr, int days, int timesPerDay, {String extraMissed = ''}) {
      final start = DateTime.tryParse(startDateStr) ?? _mockToday;
      final freqList = _expandFreqList(days, timesPerDay);
      final totalEntries = freqList.length;

      final DateTime endDate = start.add(Duration(days: days - 1));
      final bool courseEnded = endDate.isBefore(_mockToday);

      final int rawDiff = start.isAfter(_mockToday) ? -1 : _mockToday.difference(start).inDays;
      final int daysElapsed = rawDiff < 0 ? 0 : (rawDiff == 0 ? 1 : rawDiff);

      final int completedEntries = (daysElapsed * timesPerDay).clamp(0, totalEntries);

      final List<String> completed =
      completedEntries > 0 ? freqList.sublist(0, completedEntries) : <String>[];

      final List<String> missed = <String>[];
      if (courseEnded && completedEntries < totalEntries) {
        missed.addAll(freqList.sublist(completedEntries));
      }

      if (extraMissed.isNotEmpty) {
        final extra = extraMissed
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList();
        if (extra.isNotEmpty) {
          completed.removeWhere((e) => extra.contains(e));
          for (final tok in extra) {
            if (!missed.contains(tok)) missed.add(tok);
          }
        }
      }

      String note;
      if (courseEnded) {
        if (completed.length >= totalEntries && missed.isEmpty) {
          note = 'Complete';
        } else {
          note = 'Missed';
        }
      } else {
        note = 'Incomplete';
      }

      return {
        'freq_list': freqList.join(','),
        'completed_list': completed.join(','),
        'missed_list': missed.join(','),
        'note': note,
      };
    }

    // build a record map with status computed
    Map<String, String> _record(String dateStr, String drug, String dose, String means, int days, int timesPerDay,
        {String extraMissed = '', bool requireWithdrawal = false, bool forceIncomplete = false}) {
      final prog = _computeStatus(dateStr, days, timesPerDay, extraMissed: extraMissed);
      final noteVal = forceIncomplete ? 'Incomplete' : (prog['note'] ?? 'Incomplete');
      return {
        'date': dateStr,
        'drug': drug,
        'dose': dose,
        'note': noteVal,
        'means': means,
        'days': '$days',
        'times_per_day': '$timesPerDay',
        'freq_list': prog['freq_list'] ?? '',
        'completed_list': prog['completed_list'] ?? '',
        'missed_list': prog['missed_list'] ?? '',
        'withdrawal_days': requireWithdrawal && isOnMedicine ? '7' : '',
        'requires_followup': requireWithdrawal && isOnMedicine ? 'true' : 'false',
      };
    }

    // Customized mock choices: if animal is on medicine and is the 'second' one, show an ongoing course
    if (isOnMedicine && isSecond && isCow) {
      return [
        _record('2025-09-15', 'Med-Cow-A', '5 ml', 'Injection', 4, 1, requireWithdrawal: true, forceIncomplete: true),
        _record('2025-07-15', 'Med-Cow-B', '0.2 mg/kg', 'Injection', 1, 1),
      ];
    }

    if (isOnMedicine && isSecond && isHen) {
      return [
        _record('2025-09-15', 'Med-Hen-A', '1 ml', 'Oral', 2, 2, requireWithdrawal: true, forceIncomplete: true),
        _record('2025-06-10', 'Med-Hen-B', '0.5 ml', 'Spray', 1, 1),
      ];
    }

    // Default completed-ish history for first & third animals
    if (isCow) {
      return [
        _record('2025-09-01', 'Med-Cow-A', '5 ml', 'Injection', 3, 1, extraMissed: isThird ? 'Day 2' : ''),
        _record('2025-07-15', 'Med-Cow-B', '0.2 mg/kg', 'Injection', 1, 1),
      ];
    } else if (isHen) {
      return [
        _record('2025-08-20', 'Med-Hen-A', '1 ml', 'Oral', 2, 2, extraMissed: isThird ? 'Day 1 • Dose 2' : ''),
        _record('2025-07-10', 'Med-Hen-B', '0.5 ml', 'Spray', 1, 1),
      ];
    }

    return [];
  }

  @override
  Widget build(BuildContext context) {
    final Color agriGreen = MyApp.agriGreen;
    final logs = _mockAmuLogs();

    return Scaffold(
      appBar: AppBar(
        title: Text(animal.name, style: kAppBarTitle),
        backgroundColor: agriGreen,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header: big emoji + name + tag
              Card(
                color: kContainerBg,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                  child: Row(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(child: _typeEmoji(animal.type)),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(animal.name, style: kTitle.copyWith(color: kContainerText)),
                            const SizedBox(height: 6),
                            Text('Tag: ${animal.tag}', style: kSubtitle.copyWith(color: kContainerText)),
                          ],
                        ),
                      ),
                      // gender emoji + small badges
                      Column(
                        children: [
                          _genderEmoji(animal.gender),
                          const SizedBox(height: 6),
                          if (animal.pregnant)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: MyApp.saffron.withAlpha(200),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text('Pregnant', style: TextStyle(fontSize: 12)),
                            ),
                          if (animal.young)
                            Container(
                              margin: const EdgeInsets.only(top: 6),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.blueGrey.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text('Young', style: TextStyle(fontSize: 12)),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Details card
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 1,
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('Details', style: kCardHeading),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.badge_outlined, size: 18, color: Colors.black54),
                          const SizedBox(width: 10),
                          Expanded(child: Text('Tag: ${animal.tag}', style: kSubtitle)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 18, color: Colors.black54),
                          const SizedBox(width: 10),
                          Expanded(child: Text('Age: ${animal.age ?? 'N/A'}', style: kSubtitle)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.person, size: 18, color: Colors.black54),
                          const SizedBox(width: 10),
                          Expanded(child: Text('Gender: ${animal.gender ?? 'Unknown'}', style: kSubtitle)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.verified_user, size: 18, color: Colors.black54),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Pashu Aadhaar linked: ${animal.pashuAadharLinked ? 'Yes' : 'No'}',
                              style: kSubtitle,
                            ),
                          ),
                        ],
                      ),
                      if (animal.breed != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.info_outline, size: 18, color: Colors.black54),
                            const SizedBox(width: 10),
                            Expanded(child: Text('Breed: ${animal.breed}', style: kSubtitle)),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // AMU logs section — shows expandable records with frequency details
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 1,
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('AMU logs', style: kCardHeading),
                      const SizedBox(height: 8),
                      if (logs.isEmpty)
                        Text('No AMU records', style: kSubtitle)
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: logs.length,
                          separatorBuilder: (_, _) => const Divider(height: 12),
                          itemBuilder: (ctx, i) {
                            final l = logs[i];
                            final freqList = (l['freq_list'] ?? '').split(',').where((s) => s.trim().isNotEmpty).toList();
                            final missedList = (l['missed_list'] ?? '').split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toSet();
                            return ExpansionTile(
                              tilePadding: EdgeInsets.zero,
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(l['date'] ?? '', style: kSubtitle.copyWith(fontWeight: FontWeight.w600)),
                                        const SizedBox(height: 6),
                                        Text('${l['drug']} • ${l['dose']}', style: kSubtitle),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  SizedBox(
                                    width: 120,
                                    child: Text(l['note'] ?? '', textAlign: TextAlign.right, style: kSmallMuted),
                                  ),
                                ],
                              ),
                              children: [
                                const SizedBox(height: 8),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 6.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.medical_information_outlined, size: 16),
                                          const SizedBox(width: 8),
                                          Expanded(child: Text('Means: ${l['means'] ?? '-'}', style: kSubtitle)),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Icon(Icons.schedule, size: 16),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Builder(builder: (_) {
                                              final days = l['days'];
                                              final times = l['times_per_day'];
                                              if (days != null && days.isNotEmpty && times != null && times.isNotEmpty) {
                                                return Text('${times}x/day for $days day(s)', style: kSubtitle);
                                              }
                                              return Text(l['frequency'] ?? '-', style: kSubtitle);
                                            }),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 8),
                                      if (freqList.isNotEmpty) ...[
                                        const Text('Frequency details:', style: kSubtitle),
                                        const SizedBox(height: 6),
                                        Builder(builder: (_) {
                                          final completedSet = (l['completed_list'] ?? '')
                                              .split(',')
                                              .map((s) => s.trim())
                                              .where((s) => s.isNotEmpty)
                                              .toSet();
                                          final missedSet = (l['missed_list'] ?? '')
                                              .split(',')
                                              .map((s) => s.trim())
                                              .where((s) => s.isNotEmpty)
                                              .toSet();
                                          return Column(
                                            crossAxisAlignment: CrossAxisAlignment.stretch,
                                            children: [
                                              for (var f in freqList)
                                                Padding(
                                                  padding: const EdgeInsets.only(left: 8.0, bottom: 6),
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        completedSet.contains(f.trim())
                                                            ? Icons.check
                                                            : (missedSet.contains(f.trim()) ? Icons.close : Icons.remove),
                                                        size: 16,
                                                        color: completedSet.contains(f.trim())
                                                            ? Colors.green
                                                            : (missedSet.contains(f.trim()) ? Colors.red : Colors.grey),
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Expanded(
                                                        child: Text(
                                                          f.trim(),
                                                          style: kSubtitle.copyWith(
                                                            color: completedSet.contains(f.trim())
                                                                ? Colors.black
                                                                : (missedSet.contains(f.trim()) ? Colors.red : Colors.black54),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                            ],
                                          );
                                        }),
                                      ],

                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          const Icon(Icons.note, size: 16),
                                          const SizedBox(width: 8),
                                          Expanded(child: Text('Note: ${l['note'] ?? '-'}', style: kSubtitle)),
                                          if (missedList.isNotEmpty)
                                            Padding(
                                              padding: const EdgeInsets.only(left: 8.0),
                                              child: Text('Missed: ${missedList.join(', ')}', style: kSubtitle.copyWith(color: Colors.red, fontWeight: FontWeight.w700)),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),
                              ],
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        elevation: 0,
        backgroundColor: agriGreen,
        onPressed: () async {
          final bool? didLog = await openAmuLogDialog(context, initialAnimalId: animal.id);
          if (didLog == true) {
            // refresh profile route so the new manual record shows up immediately
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => AnimalProfilePage(animal: animal)),
            );
          }
        },
        label: const Text('💊', style: TextStyle(fontSize: 20, color: Colors.white)),
      ),
    );
  }
}

// -----------------------------
// Sell dialog, Mark-dead dialog,
// Withdrawal list, vet contact page
// (Same behaviour as before — only added chill comments so a normal dude gets it)
// No logic changes, purely comments / tiny docs.
// -----------------------------

class _SellDialog extends StatefulWidget {
  final List<_Animal> selectedAnimals;
  final List<String> ids;
  final String groupType; // 'Cow' or 'Hen' used to change labels
  const _SellDialog({
    required this.selectedAnimals,
    required this.ids,
    required this.groupType,
  });

  @override
  State<_SellDialog> createState() => _SellDialogState();
}

class _SellDialogState extends State<_SellDialog> {
  late final TextEditingController _sellerNameController;
  late final TextEditingController _sellerPhoneController;
  late final TextEditingController _quantityController;
  late final TextEditingController _priceController;
  bool _showError = false;

  @override
  void initState() {
    super.initState();
    // default values so the dialog looks populated in the mock
    _sellerNameController = TextEditingController(text: "Vikram Singh");
    _sellerPhoneController = TextEditingController(text: "+91 90123 45678");
    _quantityController = TextEditingController();
    _priceController = TextEditingController();
  }

  @override
  void dispose() {
    // clean up controllers — boring but necessary
    _sellerNameController.dispose();
    _sellerPhoneController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  // small helper local to the dialog (keeps things self-contained)
  Widget emojiForType(String? type) {
    switch ((type ?? '').toLowerCase()) {
      case 'cow':
        return const Text('🐄', style: TextStyle(fontSize: 20));
      case 'hen':
        return const Text('🐔', style: TextStyle(fontSize: 20));
      default:
        return const Icon(Icons.pets);
    }
  }

  @override
  Widget build(BuildContext context) {
    // size constraints so the dialog looks decent on phones/tablets
    final double dialogWidth = MediaQuery.of(context).size.width * 0.85;
    final double maxDialogHeight = MediaQuery.of(context).size.height * 0.8;
    final double listHeight =
    (widget.selectedAnimals.length * 52.0).clamp(80.0, 220.0);

    // some labels change depending on whether it's cows or hens
    final bool isCow = widget.groupType.toLowerCase() == 'cow';
    final String qtyLabel =
    isCow ? 'Milk quantity (litres)' : 'Eggs quantity (units)';

    return AlertDialog(
      title: const Text('Sell selected items'),
      content: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxDialogHeight),
        child: SingleChildScrollView(
          child: SizedBox(
            width: dialogWidth,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // header showing how many items we're selling
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Selected: ${widget.selectedAnimals.length}',
                    style: kTitle.copyWith(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 8),

                // small list of the selected animals so you can confirm
                if (widget.selectedAnimals.isNotEmpty)
                  SizedBox(
                    height: listHeight,
                    child: ListView.separated(
                      physics: const ClampingScrollPhysics(),
                      itemCount: widget.selectedAnimals.length,
                      separatorBuilder: (_, _) => const Divider(height: 8),
                      itemBuilder: (c, i) {
                        final s = widget.selectedAnimals[i];
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(child: emojiForType(s.type)),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(s.name,
                                      style: kTitle.copyWith(fontSize: 14)),
                                  const SizedBox(height: 2),
                                  Text(s.tag,
                                      style: kSubtitle.copyWith(
                                          fontSize: 12, color: Colors.black54)),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),

                const SizedBox(height: 12),

                // Seller details (required fields)
                TextField(
                  controller: _sellerNameController,
                  decoration: InputDecoration(
                    labelText: 'Seller name',
                    errorText: _showError &&
                        _sellerNameController.text.trim().isEmpty
                        ? 'Required'
                        : null,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _sellerPhoneController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(15),
                  ],
                  decoration: InputDecoration(
                    labelText: 'Seller phone',
                    errorText: _showError &&
                        _sellerPhoneController.text.trim().isEmpty
                        ? 'Required'
                        : null,
                  ),
                ),
                const SizedBox(height: 8),

                // Quantity / price — kept simple
                TextField(
                  controller: _quantityController,
                  keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    LengthLimitingTextInputFormatter(12),
                  ],
                  decoration: InputDecoration(
                    // label is short and clearer; unit shown as suffix for milk only
                    labelText: isCow ? 'Quantity' : 'Quantity',
                    hintText: isCow ? 'e.g. 2.5' : 'e.g. 12',
                    suffixText: isCow ? 'litres' : null,
                    suffixStyle:
                    const TextStyle(fontSize: 13, color: Colors.black54),
                    errorText: _showError &&
                        _quantityController.text.trim().isEmpty
                        ? 'Required'
                        : null,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _priceController,
                  keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    LengthLimitingTextInputFormatter(12),
                  ],
                  decoration: InputDecoration(
                    labelText: isCow ? 'Price (per litre)' : 'Price (per unit)',
                    prefix: Padding(
                      padding: const EdgeInsets.only(right: 6.0),
                      child: Text('₹', style: kTitle.copyWith(fontSize: 16)),
                    ),
                    hintText: isCow ? 'e.g. 50.0 (per litre)' : 'e.g. 6 (per egg)',
                    errorText: _showError && _priceController.text.trim().isEmpty
                        ? 'Required'
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            // validate locally and return a result map when OK
            final seller = _sellerNameController.text.trim();
            final phone = _sellerPhoneController.text.trim();
            final qty = _quantityController.text.trim();
            final price = _priceController.text.trim();

            if (seller.isEmpty || phone.isEmpty || qty.isEmpty || price.isEmpty) {
              setState(() => _showError = true);
              return;
            }

            Navigator.of(context).pop({
              'ids': widget.ids,
              'seller': '$seller ($phone)',
              'quantity': qty,
              'price': price,
            });
          },
          style: ElevatedButton.styleFrom(backgroundColor: MyApp.agriGreen),
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10),
            child: Text('Sell Products', style: TextStyle(color: Colors.white)),
          ),
        ),
      ],
    );
  }
}

// Replace the entire existing _MarkDeadDialog class with this updated version.
class _MarkDeadDialog extends StatefulWidget {
  final List<_Animal> selectedAnimals;
  final List<String> ids;
  const _MarkDeadDialog({
    required this.selectedAnimals,
    required this.ids,
  });

  @override
  State<_MarkDeadDialog> createState() => _MarkDeadDialogState();
}

class _MarkDeadDialogState extends State<_MarkDeadDialog> {
  late final TextEditingController _reasonController;
  bool _showError = false;

  @override
  void initState() {
    super.initState();
    _reasonController = TextEditingController();
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Widget emojiForType(String? type) {
    switch ((type ?? '').toLowerCase()) {
      case 'cow':
        return const Text('🐄', style: TextStyle(fontSize: 20));
      case 'hen':
        return const Text('🐔', style: TextStyle(fontSize: 20));
      default:
        return const Icon(Icons.pets);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double dialogWidth = MediaQuery.of(context).size.width * 0.85;
    final double maxDialogHeight = MediaQuery.of(context).size.height * 0.75;
    final double listHeight =
    (widget.selectedAnimals.length * 52.0).clamp(80.0, 200.0);

    return AlertDialog(
      title: const Text('Mark selected as deceased'),
      content: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxDialogHeight),
        child: SingleChildScrollView(
          child: SizedBox(
            width: dialogWidth,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Selected: ${widget.selectedAnimals.length}',
                    style: kTitle.copyWith(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 8),

                if (widget.selectedAnimals.isNotEmpty)
                  SizedBox(
                    height: listHeight,
                    child: ListView.separated(
                      physics: const ClampingScrollPhysics(),
                      itemCount: widget.selectedAnimals.length,
                      separatorBuilder: (_, _) => const Divider(height: 8),
                      itemBuilder: (c, i) {
                        final s = widget.selectedAnimals[i];

                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(child: emojiForType(s.type)),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(s.name, style: kTitle.copyWith(fontSize: 14)),
                                  const SizedBox(height: 2),
                                  Text(
                                    s.tag,
                                    style: kSubtitle.copyWith(
                                      fontSize: 12,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (s.pregnant)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                decoration: BoxDecoration(
                                  color: MyApp.saffron.withAlpha(200),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text('Pregnant', style: TextStyle(fontSize: 11)),
                              ),
                            if (s.young)
                              Padding(
                                padding: const EdgeInsets.only(left: 6.0),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.blueGrey.shade100,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text('Young', style: TextStyle(fontSize: 11)),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ),

                if (widget.selectedAnimals.isNotEmpty) const SizedBox(height: 12),

                // reason is required — keep it short but mandatory
                TextField(
                  controller: _reasonController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Reason (required)',
                    errorText: _showError && _reasonController.text.trim().isEmpty
                        ? 'Reason is required'
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final reason = _reasonController.text.trim();
            if (reason.isEmpty) {
              setState(() => _showError = true);
              return;
            }
            Navigator.of(context).pop({'ids': widget.ids, 'reason': reason});
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10),
            child: Text('Mark deceased', style: TextStyle(color: Colors.white)),
          ),
        ),
      ],
    );
  }
}


class WithdrawalListPage extends StatefulWidget {
  const WithdrawalListPage({super.key});

  @override
  State<WithdrawalListPage> createState() => _WithdrawalListPageState();
}

class _WithdrawalListPageState extends State<WithdrawalListPage> {
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _statusFilters = <String>{}; // 'Pregnant' | 'Young' only

  // gather animals that are flagged as "on medicine" across groups
  List<Map<String, dynamic>> _collectOnMedicine() {
    final List<Map<String, dynamic>> res = [];
    for (final g in _LivestockManagementPageState._groups) {
      for (var i = 0; i < g.count; i++) {
        final id = '${g.id}_a${i + 1}';
        final inWithdrawal = _LivestockManagementPageState._animalsOnMedicine.contains(id);
        if (!inWithdrawal) continue;

        // Reuse same generation logic used by GroupDetailPage so animals look identical
        final lowerType = g.type.toLowerCase();
        double ageYears;
        if (lowerType == 'hen') {
          final int idx = i % 3;
          ageYears = 0.3 + idx * 0.5;
          if (ageYears > 1.5) ageYears = 1.5;
        } else if (lowerType == 'cow') {
          final int idx = i % 5;
          ageYears = 1.0 + idx * 0.6;
        } else {
          ageYears = 1.0 + (i % 6);
        }

        final String gender = (lowerType == 'cow' || lowerType == 'hen')
            ? 'Female'
            : ((i % 2 == 0) ? 'Female' : 'Male');

        final String breed = g.type == 'Cow'
            ? (['Gir', 'Sahiwal', 'Tharparkar'][i % 3])
            : (['Rhode Island', 'Desi'][i % 2]);

        final bool isYoung = lowerType == 'cow'
            ? ageYears < 2.0
            : (lowerType == 'hen' ? ageYears < 0.5 : ageYears < 2.0);

        final _Animal a = _Animal(
          id: id,
          name: '${g.type} ${i + 1}',
          tag: '${g.type.substring(0, 1).toUpperCase()}${100 + i + 1}',
          type: g.type,
          breed: breed,
          gender: gender,
          age: double.parse(ageYears.toStringAsFixed(1)),
          pashuAadharLinked: (i % 5 == 0),
          pregnant: false,
          young: isYoung,
          dead: false,
          inWithdrawal: true,
        );

        res.add({'animal': a, 'groupName': g.name});
      }
    }
    return res;
  }

  // avatar that visually indicates withdrawal state
  Widget _typeAvatar(_Animal a) {
    final bg = a.inWithdrawal ? Colors.red.shade50 : Colors.white;
    final Map<String, String> emoji = {
      'cow': '🐄',
      'buffalo': '🐃',
      'hen': '🐔',
      'sheep': '🐑',
      'goat': '🐐',
      'pig': '🐖',
      'horse': '🐎',
      'dog': '🐕',
      'cat': '🐈',
    };

    final key = a.type.toLowerCase();
    final symbol = emoji.containsKey(key) ? emoji[key] : (a.type.isNotEmpty ? a.type[0].toUpperCase() : '?');

    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          symbol!,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  // apply search + status filters
  List<Map<String, dynamic>> _applyFilters(List<Map<String, dynamic>> items) {
    final q = _searchController.text.trim().toLowerCase();
    return items.where((item) {
      final a = item['animal'] as _Animal;

      final matchesQuery = q.isEmpty ||
          a.name.toLowerCase().contains(q) ||
          a.tag.toLowerCase().contains(q) ||
          (a.breed ?? '').toLowerCase().contains(q);

      final matchesStatus = _statusFilters.isEmpty ||
          (_statusFilters.contains('Pregnant') && a.pregnant) ||
          (_statusFilters.contains('Young') && a.young);

      return matchesQuery && matchesStatus;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allOnMed = _collectOnMedicine();
    final results = _applyFilters(allOnMed);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Animals on Medicine'),
        backgroundColor: MyApp.agriGreen,
        leading: BackButton(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
        child: Column(
          children: [
            // Search field with internal clear button that only appears when there is text
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Search by Name / Tag / Breed',
                  prefixIcon: const Icon(Icons.search),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  suffixIcon: _searchController.text.isEmpty
                      ? null
                      : IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {});
                    },
                  ),
                ),
              ),
            ),

            // Filter pills: All | Pregnant | Young (mutually exclusive selection)
            Row(
              children: [
                const Text('Filter:', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(width: 8),
                _MultiFilterPill(
                  label: 'All',
                  selected: _statusFilters.isEmpty,
                  selectedColor: MyApp.agriGreen,
                  onTap: () => setState(() => _statusFilters.clear()),
                ),
                const SizedBox(width: 8),
                _MultiFilterPill(
                  label: 'Pregnant',
                  selected: _statusFilters.contains('Pregnant'),
                  selectedColor: MyApp.agriGreen,
                  onTap: () => setState(() {
                    if (_statusFilters.contains('Pregnant')) _statusFilters.clear();
                    else {
                      _statusFilters.clear();
                      _statusFilters.add('Pregnant');
                    }
                  }),
                ),
                const SizedBox(width: 8),
                _MultiFilterPill(
                  label: 'Young',
                  selected: _statusFilters.contains('Young'),
                  selectedColor: MyApp.agriGreen,
                  onTap: () => setState(() {
                    if (_statusFilters.contains('Young')) _statusFilters.clear();
                    else {
                      _statusFilters.clear();
                      _statusFilters.add('Young');
                    }
                  }),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // quick counts for context
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Total on Medicine: ${allOnMed.length}   Results: ${results.length}',
                style: kSubtitle,
              ),
            ),

            const SizedBox(height: 12),

            // list of animals currently on medicine (card per animal)
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.only(bottom: 24),
                itemCount: results.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, idx) {
                  final row = results[idx];
                  final a = row['animal'] as _Animal;
                  final groupName = row['groupName'] as String;

                  return Card(
                    color: Colors.red.shade50,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.red.shade100),
                    ),
                    elevation: 2,
                    margin: EdgeInsets.zero,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () async {
                        // open animal profile when tapped
                        await Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => AnimalProfilePage(animal: a)),
                        );
                        if (mounted) setState(() {});
                      },
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
                        leading: _typeAvatar(a),
                        title: Text(a.name, style: kTitle.copyWith(fontSize: 16)),
                        subtitle: Text('$groupName • ${a.tag} • ${a.breed ?? ''}', style: kSubtitle),
                        trailing: const Icon(Icons.chevron_right, size: 26, color: Colors.black26),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}


/// Multi-select filter pill that matches the animal-list visual (green when selected)
class _MultiFilterPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color selectedColor;

  const _MultiFilterPill({
    required this.label,
    required this.selected,
    required this.onTap,
    this.selectedColor = Colors.green,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? selectedColor : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: selected ? selectedColor : Colors.grey.shade300),
          boxShadow: selected
              ? [
            BoxShadow(color: selectedColor.withOpacity(0.12), blurRadius: 6, offset: const Offset(0, 3))
          ]
              : null,
        ),
        child: Row(
          children: [
            if (selected) const Icon(Icons.check, size: 16, color: Colors.white),
            if (selected) const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(color: selected ? Colors.white : Colors.black87, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class ContactVetPage extends StatelessWidget {
  const ContactVetPage({super.key});

  // sample nearest vet data (expandable)
  static final List<Map<String, String>> _vets = [
    {
      'name': 'Greenfield Veterinary Clinic',
      'phone': '+91 98765 43210',
      'email': 'contact@greenfieldvet.example',
      'location': 'Kotwali Road, Near Market',
      'distance': '2.4 km',
    },
    {
      'name': 'Horizon Animal Care',
      'phone': '+91 91234 56789',
      'email': 'hello@horizonvet.example',
      'location': 'Industrial Estate Road, Sector 5',
      'distance': '5.1 km',
    },
    {
      'name': 'RuralVet Services',
      'phone': '+91 99887 66554',
      'email': 'support@ruralvet.example',
      'location': 'Village Road, Post Office Lane',
      'distance': '8.7 km',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final Color agriGreen = MyApp.agriGreen;
    final TextStyle titleStyle = kSubtitle.copyWith(color: Colors.black87, fontWeight: FontWeight.w600);
    final TextStyle infoStyle = kSmallMuted.copyWith(color: Colors.black87);
    final TextStyle labelStyle = kSmallMuted.copyWith(fontWeight: FontWeight.w700);

    void _copyToClipboard(BuildContext ctx, String value, String label) {
      Clipboard.setData(ClipboardData(text: value));
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(content: Text('$label copied to clipboard'),duration: const Duration(seconds: 1)),
      );
    }

    Widget _buildVetTile(BuildContext ctx, Map<String, String> vet) {
      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
          collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: agriGreen.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(child: Icon(Icons.local_hospital, color: Colors.black54)),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  vet['name'] ?? '',
                  style: titleStyle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(vet['distance'] ?? '', style: labelStyle),
            ],
          ),
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Phone row - fixed height for consistent spacing
                SizedBox(
                  height: 44,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(Icons.phone, size: 20),
                      const SizedBox(width: 12),
                      Expanded(child: SelectableText(vet['phone'] ?? '', style: infoStyle)),
                      IconButton(
                        tooltip: 'Copy phone',
                        icon: const Icon(Icons.copy, size: 20),
                        onPressed: () => _copyToClipboard(ctx, vet['phone'] ?? '', 'Phone number'),
                      ),
                    ],
                  ),
                ),

                // Divider between rows
                const Divider(height: 1),

                // Email row - fixed height matching phone row
                SizedBox(
                  height: 44,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(Icons.email, size: 20),
                      const SizedBox(width: 12),
                      Expanded(child: SelectableText(vet['email'] ?? '', style: infoStyle)),
                      IconButton(
                        tooltip: 'Copy email',
                        icon: const Icon(Icons.copy, size: 20),
                        onPressed: () => _copyToClipboard(ctx, vet['email'] ?? '', 'Email'),
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1),

                // Location row - fixed height and clickable
                InkWell(
                  onTap: () {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      const SnackBar(content: Text('Google Maps redirect — Not implemented'), duration: const Duration(seconds: 2)),
                    );
                  },
                  child: SizedBox(
                    height: 44,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(Icons.location_on, size: 20),
                        const SizedBox(width: 12),
                        Expanded(child: Text(vet['location'] ?? '', style: infoStyle)),
                        const SizedBox(width: 6),
                        const Icon(Icons.chevron_right, size: 18, color: Colors.black45),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Contact vet', style: kAppBarTitle), // use app's standard appbar style for consistent sizing
        backgroundColor: agriGreen,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Nearest veterinary services', style: kCardHeading),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.separated(
                  itemCount: _vets.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (ctx, idx) => _buildVetTile(ctx, _vets[idx]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}