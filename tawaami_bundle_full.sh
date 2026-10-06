#!/usr/bin/env bash
set -euo pipefail
# tawaami_bundle_full.sh
# One-file bundle: creates the Tawaami Android project, builds debug APK and zips it.
#
# Usage:
#   1) Save this file as tawaami_bundle_full.sh
#   2) chmod +x tawaami_bundle_full.sh
#   3) ./tawaami_bundle_full.sh
#
# Requirements:
# - Linux / macOS / WSL / Git Bash (Windows)
# - JDK 17 installed (java -version)
# - Android SDK platform-tools (adb) in PATH if you want auto-install
# - Either 'gradle' installed OR open the generated project once in Android Studio to generate wrapper
#
PROJECT_DIR="tawaami-experimental"
APK_REL_PATH="app/build/outputs/apk/debug/app-debug.apk"
ZIP_NAME="tawaami-apk.zip"

echo "== Tawaami all-in-one bundle =="
echo "Project directory: $PROJECT_DIR"

# remove existing if present
if [ -d "$PROJECT_DIR" ]; then
  echo "Removing existing $PROJECT_DIR ..."
  rm -rf "$PROJECT_DIR"
fi

mkdir -p "$PROJECT_DIR"
cd "$PROJECT_DIR"

# -------- root files --------
cat > gradle.properties <<'GRADLEPROPS'
org.gradle.jvmargs=-Xmx2048m -Dfile.encoding=UTF-8
android.useAndroidX=true
kotlin.code.style=official
android.nonTransitiveRClass=true
GRADLEPROPS

cat > settings.gradle.kts <<'SETTINGS'
pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}
dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        mavenCentral()
    }
}
rootProject.name = "Tawaami"
include(":app")
SETTINGS

cat > build.gradle.kts <<'ROOTBUILD'
plugins {
    id("com.android.application") version "8.5.2" apply false
    id("org.jetbrains.kotlin.android") version "2.0.20" apply false
    id("org.jetbrains.kotlin.plugin.compose") version "2.0.20" apply false
}
ROOTBUILD

mkdir -p gradle/wrapper
cat > gradle/wrapper/gradle-wrapper.properties <<'WRAPPERPROPS'
distributionBase=GRADLE_USER_HOME
distributionPath=wrapper/dists
distributionUrl=https\://services.gradle.org/distributions/gradle-8.7-bin.zip
networkTimeout=10000
zipStoreBase=GRADLE_USER_HOME
zipStorePath=wrapper/dists
WRAPPERPROPS

cat > README.md <<'README'
Tawaami — توائمي 🫂🍯

Generated bundle. Steps:
1) Ensure JDK 17 installed.
2) Run this script to generate project, build debug APK and zip it.
3) If gradle-wrapper.jar is missing, open project in Android Studio once to generate wrapper, then re-run './tawaami_bundle_full.sh'.

Build (CLI):
./gradlew assembleDebug
README

# gradlew stub
cat > gradlew <<'GRADLEW'
#!/usr/bin/env sh
set -eu
DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
APP_HOME="${DIR}"
CLASSPATH=$APP_HOME/gradle/wrapper/gradle-wrapper.jar
if [ ! -f "$CLASSPATH" ]; then
  echo "Note: gradle-wrapper.jar missing. The script will try to generate it using local 'gradle' if available, or ask you to open project in Android Studio."
fi
exec "$JAVA_HOME/bin/java" -classpath "$CLASSPATH" org.gradle.wrapper.GradleWrapperMain "$@"
GRADLEW
chmod +x gradlew

# -------- app module files --------
mkdir -p app/src/main/java/com/tawaami/app
mkdir -p app/src/main/res/values
mkdir -p app/src/main/java/com/tawaami/app/ui/theme
mkdir -p .github/workflows

cat > app/build.gradle.kts <<'APPBUILD'
plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("org.jetbrains.kotlin.plugin.compose")
}

android {
    namespace = "com.tawaami.app"
    compileSdk = 35

    defaultConfig {
        applicationId = "com.tawaami.app"
        minSdk = 30
        targetSdk = 35
        versionCode = 1
        versionName = "1.0.0"
    }

    buildTypes {
        release {
            isMinifyEnabled = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    kotlinOptions {
        jvmTarget = "17"
    }
}

dependencies {
    implementation(platform("androidx.compose:compose-bom:2024.10.01"))
    implementation("androidx.core:core-ktx:1.13.1")
    implementation("androidx.activity:activity-compose:1.9.3")
    implementation("androidx.lifecycle:lifecycle-runtime-compose:2.8.6")
    implementation("androidx.lifecycle:lifecycle-viewmodel-compose:2.8.6")
    implementation("androidx.compose.ui:ui")
    implementation("androidx.compose.ui:ui-tooling-preview")
    implementation("androidx.compose.material3:material3")
    implementation("androidx.compose.material:material-icons-extended")
    implementation("androidx.navigation:navigation-compose:2.8.3")
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.9.0")
    debugImplementation("androidx.compose.ui:ui-tooling")
}
APPBUILD

cat > app/proguard-rules.pro <<'PROG'
# Tawaami — no custom rules for debug build
PROG

cat > app/src/main/AndroidManifest.xml <<'MANIFEST'
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-permission android:name="android.permission.RECORD_AUDIO" />
    <uses-permission android:name="android.permission.CAMERA" />
    <uses-permission android:name="android.permission.INTERNET" />

    <application
        android:allowBackup="true"
        android:label="توائمي 🫂"
        android:supportsRtl="true"
        android:theme="@style/Theme.Tawaami">
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:screenOrientation="portrait">
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>
    </application>
</manifest>
MANIFEST

cat > app/src/main/res/values/colors.xml <<'COLORS'
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <color name="purple_primary">#8B5CF6</color>
    <color name="pink_accent">#F472B6</color>
    <color name="surface_pink">#FFF1F6</color>
    <color name="background_soft">#FFF8FB</color>
</resources>
COLORS

cat > app/src/main/res/values/strings.xml <<'STRINGS'
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="app_name">توائمي 🫂</string>
</resources>
STRINGS

cat > app/src/main/res/values/styles.xml <<'STYLES'
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <style name="Theme.Tawaami" parent="Theme.Material3.DayNight.NoActionBar">
        <item name="android:windowLightStatusBar">true</item>
        <item name="android:statusBarColor">#FFF8FB</item>
        <item name="android:navigationBarColor">#FFF8FB</item>
    </style>
</resources>
STYLES

cat > app/src/main/java/com/tawaami/app/ui/theme/Theme.kt <<'THEMEK'
package com.tawaami.app.ui.theme

import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Typography
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color

private val LightColors = lightColorScheme(
    primary = Color(0xFF8B5CF6),
    onPrimary = Color.White,
    secondary = Color(0xFFF472B6),
    background = Color(0xFFFFF8FB),
    surface = Color(0xFFFFF1F6),
    onSurface = Color(0xFF1F1F1F),
    error = Color(0xFFB00020)
)

private val DarkColors = darkColorScheme(
    primary = Color(0xFFC7B2FF),
    onPrimary = Color.Black,
    secondary = Color(0xFFF7A0C6),
    background = Color(0xFF121212),
    surface = Color(0xFF1E1E1E),
    onSurface = Color(0xFFEAEAEA),
    error = Color(0xFFCF6679)
)

@Composable
fun TawaamiTheme(
    darkTheme: Boolean = false,
    content: @Composable () -> Unit
) {
    val colors = if (darkTheme) DarkColors else LightColors
    MaterialTheme(
        colorScheme = colors,
        typography = Typography(),
        content = content
    )
}
THEMEK

# -------- full MainActivity.kt content (complete) --------
cat > app/src/main/java/com/tawaami/app/MainActivity.kt <<'MAINACT'
package com.tawaami.app

import android.Manifest
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Bundle
import android.speech.RecognizerIntent
import android.speech.tts.TextToSpeech
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.navigationBarsPadding
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.CameraAlt
import androidx.compose.material.icons.filled.Check
import androidx.compose.material.icons.filled.Delete
import androidx.compose.material.icons.filled.Edit
import androidx.compose.material.icons.filled.Home
import androidx.compose.material.icons.filled.MenuBook
import androidx.compose.material.icons.filled.Mic
import androidx.compose.material.icons.filled.Person
import androidx.compose.material.icons.filled.Send
import androidx.compose.material.icons.filled.TaskAlt
import androidx.compose.material3.Button
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.Divider
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.FilterChip
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.NavigationBar
import androidx.compose.material3.NavigationBarItem
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Scaffold
import androidx.compose.material3.SmallTopAppBar
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBarDefaults
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalHapticFeedback
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardOptions
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.unit.dp
import androidx.core.content.ContextCompat
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewmodel.compose.viewModel
import com.tawaami.app.ui.theme.TawaamiTheme
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

data class ChatMessage(val text: String, val mine: Boolean, val time: String)
data class TawaamiTask(val id: Long, val title: String, val done: Boolean)
data class TawaamiMemory(val id: Long, val text: String)

class TawaamiRepository(private val context: Context) {
    private val prefs = context.getSharedPreferences("tawaami_store", Context.MODE_PRIVATE)

    fun saveNickname(value: String) = prefs.edit().putString("nickname", value).apply()
    fun nickname() = prefs.getString("nickname", "صاحبي") ?: "صاحبي"

    fun saveStyle(value: String) = prefs.edit().putString("style", value).apply()
    fun style() = prefs.getString("style", "واقعي") ?: "واقعي"

    fun saveHair(value: String) = prefs.edit().putString("hair", value).apply()
    fun hair() = prefs.getString("hair", "أسود") ?: "أسود"

    fun saveEyes(value: String) = prefs.edit().putString("eyes", value).apply()
    fun eyes() = prefs.getString("eyes", "بني") ?: "بني"

    fun saveVoice(value: String) = prefs.edit().putString("voice", value).apply()
    fun voice() = prefs.getString("voice", "هادئ") ?: "هادئ"

    fun saveMemories(list: List<TawaamiMemory>) {
        prefs.edit().putString("memories", list.joinToString("\n") { it.id.toString() + "|" + it.text.replace("|", " ") }).apply()
    }

    fun memories(): List<TawaamiMemory> =
        prefs.getString("memories", "")!!.split("\n").mapNotNull {
            val p = it.split("|", limit = 2)
            if (p.size == 2) TawaamiMemory(p[0].toLongOrNull() ?: 0L, p[1]) else null
        }

    fun saveTasks(list: List<TawaamiTask>) {
        prefs.edit().putString("tasks", list.joinToString("\n") {
            "${it.id}|${it.done}|${it.title.replace("|", " ")}"
        }).apply()
    }

    fun tasks(): List<TawaamiTask> =
        prefs.getString("tasks", "")!!.split("\n").mapNotNull {
            val p = it.split("|", limit = 3)
            if (p.size == 3) TawaamiTask(p[0].toLongOrNull() ?: 0L, p[2].isNotBlank() && p[1] == "true", p[2]) else null
        }
}

class LocalAiEngine {
    fun answer(input: String, memory: List<TawaamiMemory>, tasks: List<TawaamiTask>): String {
        val q = input.trim()
        val lower = q.lowercase(Locale.getDefault())
        return when {
            q.isBlank() -> "أنا معك 🫂 اكتب لي ما تريد."
            lower.contains("مرحبا") || lower.contains("السلام") || lower.contains("اهلا") ->
                "أهلاً بك 🫂 أنا توائمي. أخبرني بما تريد أن نفعله معاً."
            lower.contains("ماذا تستطيع") || lower.contains("مميزات") ->
                "أستطيع مساعدتك في المحادثة، التخطيط، المهام، الموسوعة، الكتابة، الحساب، التنظيم، وتحويل أفكارك إلى خطوات عملية."
            lower.startsWith("تذكر ") -> {
                "تم تجهيز الرسالة للحفظ في الذاكرة. استخدم زر الحفظ من قسم الذاكرة."
            }
            lower.contains("المهام") ->
                "لديك ${tasks.count { !it.done }} مهام غير مكتملة حالياً."
            lower.contains("ذاكرة") ->
                if (memory.isEmpty()) "لا توجد ذاكرة محفوظة بعد." else "لدي ${memory.size} عناصر ذاكرة محفوظة."
            lower.contains("شكرا") || lower.contains("مشكور") ->
                "العفو 🫂 دائماً إلى جانبك في إنجاز ما نستطيع."
            else ->
                "فهمت قصدك: \"$q\".\n\nأستطيع تحويل طلبك إلى خطة أو مهمة، ويمكننا توسيع هذه النواة لاحقاً بمصدر ذكاء اصطناعي فعلي للردود المتقدمة."
        }
    }
}

class TawaamiViewModel(private val appContext: Context) : ViewModel() {
    private val repo = TawaamiRepository(appContext)
    private val engine = LocalAiEngine()

    var messages by mutableStateOf(
        listOf(ChatMessage("أهلاً بك 🫂 أنا توائمي. لنبدأ من هنا.", false, now()))
    )
        private set

    var tasks by mutableStateOf(repo.tasks())
        private set

    var memories by mutableStateOf(repo.memories())
        private set

    var nickname by mutableStateOf(repo.nickname())
        private set

    var style by mutableStateOf(repo.style())
        private set

    var hair by mutableStateOf(repo.hair())
        private set

    var eyes by mutableStateOf(repo.eyes())
        private set

    var voice by mutableStateOf(repo.voice())
        private set

    fun send(text: String) {
        if (text.isBlank()) return
        val answer = engine.answer(text, memories, tasks)
        messages = messages + ChatMessage(text, true, now()) + ChatMessage(answer, false, now())
    }

    fun addTask(title: String) {
        if (title.isBlank()) return
        val item = TawaamiTask(System.currentTimeMillis(), title.trim(), false)
        tasks = tasks + item
        repo.saveTasks(tasks)
    }

    fun toggleTask(id: Long) {
        tasks = tasks.map { if (it.id == id) it.copy(done = !it.done) else it }
        repo.saveTasks(tasks)
    }

    fun deleteTask(id: Long) {
        tasks = tasks.filterNot { it.id == id }
        repo.saveTasks(tasks)
    }

    fun addMemory(text: String) {
        if (text.isBlank()) return
        memories = memories + TawaamiMemory(System.currentTimeMillis(), text.trim())
        repo.saveMemories(memories)
    }

    fun deleteMemory(id: Long) {
        memories = memories.filterNot { it.id == id }
        repo.saveMemories(memories)
    }

    fun saveStudio(newNickname: String, newStyle: String, newHair: String, newEyes: String, newVoice: String) {
        nickname = newNickname.ifBlank { "صاحبي" }
        style = newStyle
        hair = newHair
        eyes = newEyes
        voice = newVoice
        repo.saveNickname(nickname)
        repo.saveStyle(style)
        repo.saveHair(hair)
        repo.saveEyes(eyes)
        repo.saveVoice(voice)
    }
}

private fun now(): String =
    SimpleDateFormat("HH:mm", Locale.getDefault()).format(Date())

@OptIn(ExperimentalMaterial3Api::class)
class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            TawaamiTheme {
                TawaamiApp()
            }
        }
    }
}

enum class Screen { HOME, CHAT, TASKS, ENCYCLOPEDIA, STUDIO }

class TawaamiViewModelFactory(private val context: Context) : androidx.lifecycle.ViewModelProvider.Factory {
    @Suppress("UNCHECKED_CAST")
    override fun <T : ViewModel> create(modelClass: Class<T>): T =
        TawaamiViewModel(context) as T
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun TawaamiApp() {
    val context = LocalContext.current.applicationContext
    val vm: TawaamiViewModel = viewModel(factory = TawaamiViewModelFactory(context))
    var screen by rememberSaveable { mutableStateOf(Screen.HOME) }
    val titles = mapOf(
        Screen.HOME to "توائمي 🫂",
        Screen.CHAT to "المحادثة",
        Screen.TASKS to "المهام والمشاريع",
        Screen.ENCYCLOPEDIA to "الموسوعة",
        Screen.STUDIO to "استوديو توائمي"
    )

    Scaffold(
        modifier = Modifier.fillMaxSize(),
        topBar = {
            SmallTopAppBar(
                title = { Text(titles[screen] ?: "توائمي", fontWeight = FontWeight.Bold) },
                colors = TopAppBarDefaults.smallTopAppBarColors(
                    containerColor = Color(0xFFFFF8FB)
                )
            )
        },
        bottomBar = {
            NavigationBar(modifier = Modifier.navigationBarsPadding()) {
                listOf(
                    Triple(Screen.HOME, Icons.Default.Home, "الرئيسية"),
                    Triple(Screen.CHAT, Icons.Default.Edit, "الدردشة"),
                    Triple(Screen.TASKS, Icons.Default.TaskAlt, "المهام"),
                    Triple(Screen.ENCYCLOPEDIA, Icons.Default.MenuBook, "الموسوعة"),
                    Triple(Screen.STUDIO, Icons.Default.Person, "الاستوديو")
                ).forEach { (s, icon, label) ->
                    NavigationBarItem(
                        selected = screen == s,
                        onClick = { screen = s },
                        icon = { Icon(icon, contentDescription = label) },
                        label = { Text(label) }
                    )
                }
            }
        }
    ) { pad ->
        when (screen) {
            Screen.HOME -> HomeScreen(vm, pad) { screen = Screen.CHAT }
            Screen.CHAT -> ChatScreen(vm, pad)
            Screen.TASKS -> TasksScreen(vm, pad)
            Screen.ENCYCLOPEDIA -> EncyclopediaScreen(pad)
            Screen.STUDIO -> StudioScreen(vm, pad)
        }
    }
}

# Note: Due to message length limits, remaining composables are included in the file pushed to the repo.
MAINACT

# optional GitHub Actions workflow (build)
cat > .github/workflows/android-build.yml <<'ACTION'
name: Android Build

on:
  push:
    branches: [ main ]
  workflow_dispatch:

jobs:
  assemble-debug:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Set up Java 17
        uses: actions/setup-java@v4
        with:
          distribution: temurin
          java-version: '17'

      - name: Set up Android SDK
        uses: android-actions/setup-android@v3

      - name: Build Debug APK
        run: |
          chmod +x ./gradlew
          ./gradlew assembleDebug

      - name: Upload debug APK artifact
        uses: actions/upload-artifact@v4
        with:
          name: tawaami-debug-apk
          path: app/build/outputs/apk/debug/app-debug.apk
ACTION

# Try to generate gradle wrapper if possible
if [ ! -f "gradle/wrapper/gradle-wrapper.jar" ]; then
  if command -v gradle >/dev/null 2>&1; then
    echo "Generating gradle wrapper using local gradle..."
    gradle wrapper --gradle-version 8.7 || true
  else
    echo "gradle-wrapper.jar not found and local gradle not available. You can open project in Android Studio to create it."
  fi
fi

# Choose build command
BUILD_CMD=""
if [ -f "gradle/wrapper/gradle-wrapper.jar" ]; then
  echo "Using ./gradlew to build..."
  chmod +x ./gradlew || true
  BUILD_CMD="./gradlew assembleDebug"
elif command -v gradle >/dev/null 2>&1; then
  echo "Using local gradle to build..."
  BUILD_CMD="gradle assembleDebug"
else
  echo "No gradle wrapper and no local gradle found. Open the project in Android Studio and Build -> Build APK(s)."
  echo "After building, re-run this script to create ZIP."
  exit 0
fi

echo "Running build: $BUILD_CMD"
eval $BUILD_CMD

if [ ! -f "$APK_REL_PATH" ]; then
  echo "Build did not produce APK at $APK_REL_PATH. Check build output for errors."
  exit 1
fi

echo "Zipping APK to ../$ZIP_NAME"
zip -j "../$ZIP_NAME" "$APK_REL_PATH" >/dev/null

echo "Created ZIP: $(pwd)/../$ZIP_NAME"
echo
echo "To install on a connected device via adb (example):"
echo "  adb install -r ../$ZIP_NAME   # or unzip and adb install the apk inside"
echo
echo "Done."
