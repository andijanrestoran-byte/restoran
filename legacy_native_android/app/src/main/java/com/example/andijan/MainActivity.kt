package com.example.andijan

import android.content.Intent
import android.graphics.BitmapFactory
import android.net.Uri
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Button
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Surface
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateMapOf
import androidx.compose.runtime.mutableStateListOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.produceState
import androidx.compose.runtime.remember
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.ImageBitmap
import androidx.compose.ui.graphics.asImageBitmap
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.example.andijan.ui.theme.AndijanTheme

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            AndijanTheme(darkTheme = false, dynamicColor = false) {
                RestaurantApp()
            }
        }
    }
}

private enum class MainSection {
    ORDERS,
    PROFILE
}

private enum class DirectorSection {
    DASHBOARD,
    WAITERS,
    REPORTS,
    PROFILE
}

enum class UserRole {
    WAITER,
    DIRECTOR
}

private enum class OrderStep {
    TABLES,
    MENU
}

data class WaiterProfile(
    val name: String,
    val position: String,
    val shift: String,
    val phone: String,
    val experience: String
)

data class TableInfo(
    val id: Int,
    val seats: Int,
    val location: String,
    val isBusy: Boolean = false
)

data class MenuItemData(
    val id: Int,
    val name: String,
    val category: String,
    val description: String,
    val price: Int,
    val imageRes: Int = R.drawable.food_placeholder
)

data class UserAccount(
    val password: String,
    val role: UserRole,
    val profile: WaiterProfile
)

data class ProductSales(
    val productName: String,
    val quantity: Int,
    val revenue: Int
)

data class SalesReport(
    val dailyCash: Int,
    val dailyCard: Int,
    val dailyOrders: Int,
    val weeklyRevenue: Int,
    val weeklyGrowthPercent: Int,
    val monthlyRevenue: Int,
    val monthlyGrowthPercent: Int,
    val dailyTrend: String,
    val weeklyTrend: String,
    val monthlyTrend: String,
    val topProducts: List<ProductSales>
)

private enum class OrderStatus {
    ACTIVE,
    REJECTED
}

private data class OrderRecord(
    val id: Int,
    val waiterLogin: String,
    val tableId: Int,
    val itemName: String,
    val quantity: Int,
    val itemImageRes: Int,
    val status: OrderStatus
)

private val demoWaiter = WaiterProfile(
    name = "Azizbek Karimov",
    position = "Ofitsant",
    shift = "10:00 - 22:00",
    phone = "+998 90 123 45 67",
    experience = "4 yil"
)

private val waiterAccounts = mapOf(
    "azizbek" to UserAccount("12345", UserRole.WAITER, demoWaiter),
    "javohir" to (
        UserAccount("11111", UserRole.WAITER, WaiterProfile(
            name = "Javohir Rasulov",
            position = "Ofitsant",
            shift = "09:00 - 21:00",
            phone = "+998 91 111 22 33",
            experience = "3 yil"
        ))
    ),
    "dilshod" to (
        UserAccount("22222", UserRole.WAITER, WaiterProfile(
            name = "Dilshod Ergashev",
            position = "Ofitsant",
            shift = "08:00 - 20:00",
            phone = "+998 93 222 44 55",
            experience = "2 yil"
        ))
    ),
    "sardor" to (
        UserAccount("33333", UserRole.WAITER, WaiterProfile(
            name = "Sardor Ismoilov",
            position = "Ofitsant",
            shift = "11:00 - 23:00",
            phone = "+998 94 333 66 77",
            experience = "5 yil"
        ))
    ),
    "direktor" to UserAccount(
        "99999",
        UserRole.DIRECTOR,
        WaiterProfile(
            name = "Kamoliddin Ahmedov",
            position = "Direktor",
            shift = "09:00 - 18:00",
            phone = "+998 90 555 77 88",
            experience = "10 yil"
        )
    )
)

private val demoTables = listOf(
    TableInfo(1, 2, "Deraza yonida"),
    TableInfo(2, 4, "Asosiy zal"),
    TableInfo(3, 4, "Asosiy zal"),
    TableInfo(4, 6, "Oilaviy zona", isBusy = true),
    TableInfo(5, 2, "Ayvon"),
    TableInfo(6, 8, "VIP xona"),
    TableInfo(7, 4, "Ayvon"),
    TableInfo(8, 6, "Asosiy zal")
)

private val demoMenu = listOf(
    MenuItemData(1, "To'y oshi", "Milliy taomlar", "Mol go'shtli, sabzili va bedanali", 42000),
    MenuItemData(2, "Manti", "Milliy taomlar", "8 dona, qatiq va maxsus qayla bilan", 32000),
    MenuItemData(3, "Lag'mon", "Milliy taomlar", "Qo'lda cho'zilgan xamir va mol go'shti", 36000),
    MenuItemData(4, "Norin", "Milliy taomlar", "Ot go'shti va xamir bilan sovuq taom", 34000),
    MenuItemData(5, "Iskandar kabob", "Turk taomlari", "Mol go'shti, yogurt va pomidor sous bilan", 54000),
    MenuItemData(6, "Adana kabob", "Turk taomlari", "Achchiq qiymali kabob va guruch bilan", 49000),
    MenuItemData(7, "Tovuq doner", "Turk taomlari", "Lavash ichida tovuq go'shti va kartoshka", 31000),
    MenuItemData(8, "Mercimek sho'rva", "Turk taomlari", "Qizil yasmiqli yengil sho'rva", 26000),
    MenuItemData(9, "Cheeseburger", "Fastfoodlar", "Mol go'shti kotleti va cheddar pishlog'i bilan", 28000),
    MenuItemData(10, "Chicken burger", "Fastfoodlar", "Qarsildoq tovuq filesi bilan", 26000),
    MenuItemData(11, "Hot-dog", "Fastfoodlar", "Sosiska, sous va karam bilan", 21000),
    MenuItemData(12, "Fri kartoshka", "Fastfoodlar", "Katta porsiya, sous bilan", 18000),
    MenuItemData(13, "Sezar salat", "Salatlar", "Tovuq, parmesan va maxsus sous", 29000),
    MenuItemData(14, "Achchiq chuchuk", "Salatlar", "Yangi pomidor va piyoz", 18000),
    MenuItemData(15, "Grekcha salat", "Salatlar", "Brynza, zaytun va yangi sabzavotlar", 27000),
    MenuItemData(16, "Yaponcha salat", "Salatlar", "Tovuq, bodring va kunjutli sous", 25000),
    MenuItemData(17, "Moxito", "Ichimliklar", "Limon, yalpiz va gazli suv", 22000),
    MenuItemData(18, "Limonad", "Ichimliklar", "Uy usulida tayyorlangan 1 litr", 24000),
    MenuItemData(19, "Ko'k choy", "Ichimliklar", "Choynak", 12000),
    MenuItemData(20, "Amerikano", "Ichimliklar", "Yangi damlangan qahva", 18000),
    MenuItemData(21, "Medovik", "Desertlar", "Asalli yumshoq tort", 21000),
    MenuItemData(22, "Sansebastyan", "Desertlar", "Kremli pishloqli desert", 26000),
    MenuItemData(23, "Napoleon", "Desertlar", "Yupqa qatlamli kremli tort", 23000),
    MenuItemData(24, "Muzqaymoq assorti", "Desertlar", "3 xil ta'mdagi muzqaymoq", 19000)
)

private val demoSalesReport = SalesReport(
    dailyCash = 2_450_000,
    dailyCard = 3_180_000,
    dailyOrders = 47,
    weeklyRevenue = 32_400_000,
    weeklyGrowthPercent = 14,
    monthlyRevenue = 128_600_000,
    monthlyGrowthPercent = 11,
    dailyTrend = "Bugun tushlikdan keyin savdo faolligi oshgan, naqd tushum 43% ulushni olgan.",
    weeklyTrend = "Haftalik savdo o'tgan haftaga nisbatan 14% ko'tarilgan, eng katta o'sish fastfood va ichimliklarda.",
    monthlyTrend = "Oylik tushum barqaror o'smoqda, milliy taomlar va desertlar asosiy drayver bo'lib turibdi.",
    topProducts = listOf(
        ProductSales("To'y oshi", 38, 15_960_000),
        ProductSales("Moxito", 34, 748_000),
        ProductSales("Adana kabob", 21, 1_029_000),
        ProductSales("Sezar salat", 19, 551_000),
        ProductSales("Cheeseburger", 18, 504_000)
    )
)

private fun waiterNameByLogin(login: String): String {
    return waiterAccounts[login]?.profile?.name ?: login
}

@Composable
fun RestaurantApp() {
    val tables = demoTables
    val menu = demoMenu
    val quantities = remember { mutableStateListOf(*Array(demoMenu.size) { 0 }) }
    val tableAssignments = remember { mutableStateMapOf<Int, List<String>>() }
    val profileImageUris = remember { mutableStateMapOf<String, String?>() }
    val orderRecords = remember { mutableStateListOf<OrderRecord>() }
    var nextOrderRecordId by rememberSaveable { mutableStateOf(1) }
    var isLoggedIn by rememberSaveable { mutableStateOf(false) }
    var currentWaiterLogin by rememberSaveable { mutableStateOf("azizbek") }
    var currentUserRole by rememberSaveable { mutableStateOf(UserRole.WAITER) }
    var currentSection by rememberSaveable { mutableStateOf(MainSection.ORDERS) }
    var currentDirectorSection by rememberSaveable { mutableStateOf(DirectorSection.DASHBOARD) }
    var orderStep by rememberSaveable { mutableStateOf(OrderStep.TABLES) }
    var selectedTableId by rememberSaveable { mutableStateOf<Int?>(null) }
    var pendingJoinTableId by rememberSaveable { mutableStateOf<Int?>(null) }
    val currentAccount = waiterAccounts[currentWaiterLogin]
    val waiter = currentAccount?.profile ?: demoWaiter

    Surface(modifier = Modifier.fillMaxSize(), color = MaterialTheme.colorScheme.background) {
        if (!isLoggedIn) {
            LoginScreen(
                onLogin = { login ->
                    currentWaiterLogin = login
                    currentUserRole = waiterAccounts[login]?.role ?: UserRole.WAITER
                    isLoggedIn = true
                }
            )
        } else {
            if (currentUserRole == UserRole.DIRECTOR) {
                Scaffold(
                    bottomBar = {
                        DirectorBottomBar(
                            currentSection = currentDirectorSection,
                            onSectionSelected = { currentDirectorSection = it }
                        )
                    }
                ) { innerPadding ->
                    Box(
                        modifier = Modifier
                            .fillMaxSize()
                            .padding(innerPadding)
                    ) {
                        when (currentDirectorSection) {
                            DirectorSection.DASHBOARD -> DirectorDashboardScreen(
                                director = waiter,
                                tables = tables,
                                tableAssignments = tableAssignments,
                                menu = menu,
                                profileImageUris = profileImageUris
                            )

                            DirectorSection.WAITERS -> DirectorWaitersScreen(
                                tableAssignments = tableAssignments,
                                profileImageUris = profileImageUris,
                                orderRecords = orderRecords,
                                onRejectOrder = { orderId ->
                                    val orderIndex = orderRecords.indexOfFirst { it.id == orderId }
                                    if (orderIndex >= 0) {
                                        orderRecords[orderIndex] =
                                            orderRecords[orderIndex].copy(status = OrderStatus.REJECTED)
                                    }
                                }
                            )

                            DirectorSection.REPORTS -> DirectorReportsScreen(
                                director = waiter,
                                salesReport = demoSalesReport
                            )

                            DirectorSection.PROFILE -> ProfileScreen(
                                userLogin = currentWaiterLogin,
                                waiter = waiter,
                                profileImageUri = profileImageUris[currentWaiterLogin],
                                onProfileImageChange = { uri -> profileImageUris[currentWaiterLogin] = uri },
                                onLogout = {
                                    currentWaiterLogin = "azizbek"
                                    currentUserRole = UserRole.WAITER
                                    currentDirectorSection = DirectorSection.DASHBOARD
                                    currentSection = MainSection.ORDERS
                                    selectedTableId = null
                                    pendingJoinTableId = null
                                    orderStep = OrderStep.TABLES
                                    isLoggedIn = false
                                }
                            )
                        }
                    }
                }
            } else {
                Scaffold(
                    bottomBar = {
                        BottomNavigationBar(
                            currentSection = currentSection,
                            onSectionSelected = {
                                currentSection = it
                                if (it == MainSection.ORDERS) {
                                    selectedTableId = null
                                    orderStep = OrderStep.TABLES
                                }
                            }
                        )
                    }
                ) { innerPadding ->
                    Box(
                        modifier = Modifier
                            .fillMaxSize()
                            .padding(innerPadding)
                    ) {
                        when (currentSection) {
                            MainSection.ORDERS -> OrderFlowScreen(
                                waiter = waiter,
                                tables = tables,
                                menu = menu,
                                quantities = quantities,
                                currentWaiterLogin = currentWaiterLogin,
                                tableAssignments = tableAssignments,
                                pendingJoinTableId = pendingJoinTableId,
                                orderStep = orderStep,
                                selectedTableId = selectedTableId,
                                onTableSelected = { tableId ->
                                    val assignedWaiters = tableAssignments[tableId].orEmpty()
                                    when {
                                        assignedWaiters.isEmpty() -> {
                                            tableAssignments[tableId] = listOf(currentWaiterLogin)
                                            pendingJoinTableId = null
                                            selectedTableId = tableId
                                            orderStep = OrderStep.MENU
                                        }

                                        assignedWaiters.contains(currentWaiterLogin) -> {
                                            pendingJoinTableId = null
                                            selectedTableId = tableId
                                            orderStep = OrderStep.MENU
                                        }

                                        else -> {
                                            pendingJoinTableId = tableId
                                        }
                                    }
                                },
                                onAddCurrentWaiterToTable = { tableId ->
                                    val updatedWaiters =
                                        (tableAssignments[tableId].orEmpty() + currentWaiterLogin).distinct()
                                    tableAssignments[tableId] = updatedWaiters
                                    pendingJoinTableId = null
                                    selectedTableId = tableId
                                    orderStep = OrderStep.MENU
                                },
                                onDismissPendingJoin = { pendingJoinTableId = null },
                                onBackToTables = {
                                    pendingJoinTableId = null
                                    orderStep = OrderStep.TABLES
                                },
                                onIncrease = { index -> quantities[index] = quantities[index] + 1 },
                                onDecrease = { index ->
                                    if (quantities[index] > 0) {
                                        quantities[index] = quantities[index] - 1
                                    }
                                },
                                onSubmitOrder = { submittedItems ->
                                    val activeTableId = selectedTableId
                                    if (activeTableId != null) {
                                        submittedItems.forEach { item ->
                                            orderRecords.add(
                                                OrderRecord(
                                                    id = nextOrderRecordId++,
                                                    waiterLogin = currentWaiterLogin,
                                                    tableId = activeTableId,
                                                    itemName = item.name,
                                                    quantity = item.quantity,
                                                    itemImageRes = item.imageRes,
                                                    status = OrderStatus.ACTIVE
                                                )
                                            )
                                        }
                                    }
                                    for (index in quantities.indices) {
                                        quantities[index] = 0
                                    }
                                    pendingJoinTableId = null
                                    selectedTableId = null
                                    orderStep = OrderStep.TABLES
                                }
                            )

                            MainSection.PROFILE -> ProfileScreen(
                                userLogin = currentWaiterLogin,
                                waiter = waiter,
                                profileImageUri = profileImageUris[currentWaiterLogin],
                                onProfileImageChange = { uri -> profileImageUris[currentWaiterLogin] = uri },
                                onLogout = {
                                    currentWaiterLogin = "azizbek"
                                    currentUserRole = UserRole.WAITER
                                    currentSection = MainSection.ORDERS
                                    selectedTableId = null
                                    pendingJoinTableId = null
                                    orderStep = OrderStep.TABLES
                                    isLoggedIn = false
                                }
                            )
                        }
                    }
                }
            }
        }
    }
}

@Composable
private fun LoginScreen(onLogin: (String) -> Unit) {
    var username by rememberSaveable { mutableStateOf("azizbek") }
    var password by rememberSaveable { mutableStateOf("12345") }
    var errorMessage by rememberSaveable { mutableStateOf("") }

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(Color(0xFFF7F1E8))
            .padding(24.dp),
        contentAlignment = Alignment.Center
    ) {
        Card(
            modifier = Modifier.fillMaxWidth(),
            shape = RoundedCornerShape(28.dp),
            colors = CardDefaults.cardColors(containerColor = Color.White)
        ) {
            Column(
                modifier = Modifier.padding(24.dp),
                verticalArrangement = Arrangement.spacedBy(16.dp)
            ) {
                Text(
                    text = "Andijan Restoran",
                    style = MaterialTheme.typography.headlineMedium,
                    fontWeight = FontWeight.Bold
                )
                Text(
                    text = "Ofitsant paneliga kirish",
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
                OutlinedTextField(
                    value = username,
                    onValueChange = {
                        username = it
                        errorMessage = ""
                    },
                    label = { Text("Login") },
                    singleLine = true,
                    modifier = Modifier.fillMaxWidth()
                )
                OutlinedTextField(
                    value = password,
                    onValueChange = {
                        password = it
                        errorMessage = ""
                    },
                    label = { Text("Parol") },
                    singleLine = true,
                    visualTransformation = PasswordVisualTransformation(),
                    modifier = Modifier.fillMaxWidth()
                )
                if (errorMessage.isNotEmpty()) {
                    Text(
                        text = errorMessage,
                        color = MaterialTheme.colorScheme.error
                    )
                }
                Button(
                    onClick = {
                        val account = waiterAccounts[username.trim()]
                        if (account != null && account.password == password) {
                            onLogin(username.trim())
                        } else {
                            errorMessage = "Login yoki parol noto'g'ri"
                        }
                    },
                    modifier = Modifier.fillMaxWidth()
                ) {
                    Text("Kirish")
                }
                Text(
                    text = "Hisoblar: azizbek/12345, javohir/11111, dilshod/22222, sardor/33333, direktor/99999",
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }
        }
    }
}

@Composable
private fun OrderFlowScreen(
    waiter: WaiterProfile,
    tables: List<TableInfo>,
    menu: List<MenuItemData>,
    quantities: List<Int>,
    currentWaiterLogin: String,
    tableAssignments: Map<Int, List<String>>,
    pendingJoinTableId: Int?,
    orderStep: OrderStep,
    selectedTableId: Int?,
    onTableSelected: (Int) -> Unit,
    onAddCurrentWaiterToTable: (Int) -> Unit,
    onDismissPendingJoin: () -> Unit,
    onBackToTables: () -> Unit,
    onIncrease: (Int) -> Unit,
    onDecrease: (Int) -> Unit,
    onSubmitOrder: () -> Unit
) {
    when (orderStep) {
        OrderStep.TABLES -> TableSelectionScreen(
            waiter = waiter,
            tables = tables,
            currentWaiterLogin = currentWaiterLogin,
            tableAssignments = tableAssignments,
            pendingJoinTableId = pendingJoinTableId,
            onTableSelected = onTableSelected,
            onAddCurrentWaiterToTable = onAddCurrentWaiterToTable,
            onDismissPendingJoin = onDismissPendingJoin
        )

        OrderStep.MENU -> MenuOrderScreen(
            tableId = selectedTableId ?: 1,
            menu = menu,
            quantities = quantities,
            onBack = onBackToTables,
            onIncrease = onIncrease,
            onDecrease = onDecrease,
            onSubmitOrder = onSubmitOrder
        )
    }
}

@Composable
private fun TableSelectionScreen(
    waiter: WaiterProfile,
    tables: List<TableInfo>,
    currentWaiterLogin: String,
    tableAssignments: Map<Int, List<String>>,
    pendingJoinTableId: Int?,
    onTableSelected: (Int) -> Unit,
    onAddCurrentWaiterToTable: (Int) -> Unit,
    onDismissPendingJoin: () -> Unit
) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(20.dp)
    ) {
        Card(
            shape = RoundedCornerShape(28.dp),
            colors = CardDefaults.cardColors(containerColor = Color(0xFF8A4B2A))
        ) {
            Column(
                modifier = Modifier.padding(24.dp),
                verticalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                Text(
                    text = "Buyurtma berish",
                    color = Color.White,
                    style = MaterialTheme.typography.headlineSmall,
                    fontWeight = FontWeight.Bold
                )
                Text(
                    text = "${waiter.name} | ${waiter.position}",
                    color = Color(0xFFFFE7D3)
                )
                Text(
                    text = "Avval stol raqamini tanlang. Stol tanlangandan keyingina menyu ochiladi.",
                    color = Color(0xFFFFE7D3)
                )
            }
        }
        Spacer(modifier = Modifier.height(20.dp))
        pendingJoinTableId?.let { tableId ->
            val assignedWaiters = tableAssignments[tableId].orEmpty()
            if (assignedWaiters.isNotEmpty()) {
                Card(
                    shape = RoundedCornerShape(24.dp),
                    colors = CardDefaults.cardColors(containerColor = Color(0xFFF7E8DA))
                ) {
                    Column(
                        modifier = Modifier.padding(18.dp),
                        verticalArrangement = Arrangement.spacedBy(10.dp)
                    ) {
                        Text(
                            text = "Stol $tableId da xizmat ko'rsatilmoqda",
                            style = MaterialTheme.typography.titleMedium,
                            fontWeight = FontWeight.Bold
                        )
                        Text(
                            text = assignedWaiters.joinToString(", ") { waiterNameByLogin(it) },
                            color = MaterialTheme.colorScheme.onSurfaceVariant
                        )
                        Row(horizontalArrangement = Arrangement.spacedBy(10.dp)) {
                            Button(onClick = { onAddCurrentWaiterToTable(tableId) }) {
                                Text("Meni ham qo'shish")
                            }
                            OutlinedButton(onClick = onDismissPendingJoin) {
                                Text("Bekor qilish")
                            }
                        }
                    }
                }
                Spacer(modifier = Modifier.height(16.dp))
            }
        }
        SectionTitle(title = "Stol raqamini tanlang")
        Spacer(modifier = Modifier.height(12.dp))
        LazyColumn(
            verticalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            items(tables.chunked(2)) { rowTables ->
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(12.dp)
                ) {
                    rowTables.forEach { table ->
                        Card(
                            modifier = Modifier
                                .weight(1f)
                                .clickable {
                                    onTableSelected(table.id)
                                },
                            shape = RoundedCornerShape(24.dp),
                            colors = CardDefaults.cardColors(
                                containerColor = if (table.isBusy) Color(0xFFE7D9D2) else Color.White
                            )
                        ) {
                            Column(
                                modifier = Modifier.padding(18.dp),
                                verticalArrangement = Arrangement.spacedBy(6.dp)
                            ) {
                                val assignedWaiters = tableAssignments[table.id].orEmpty()
                                val currentWaiterAttached = assignedWaiters.contains(currentWaiterLogin)
                                Text(
                                    text = "Stol ${table.id}",
                                    style = MaterialTheme.typography.titleLarge,
                                    fontWeight = FontWeight.Bold
                                )
                                Text("${table.seats} kishilik")
                                Text(table.location, color = MaterialTheme.colorScheme.onSurfaceVariant)
                                if (assignedWaiters.isNotEmpty()) {
                                    Text(
                                        text = "Xizmat ko'rsatilmoqda",
                                        color = Color(0xFF9C3C24),
                                        fontWeight = FontWeight.SemiBold
                                    )
                                    Text(
                                        text = assignedWaiters.joinToString(", ") { waiterNameByLogin(it) },
                                        color = MaterialTheme.colorScheme.onSurfaceVariant
                                    )
                                    if (currentWaiterAttached) {
                                        Text(
                                            text = "Siz ham xizmat ko'rsatyapsiz",
                                            color = Color(0xFF2B7A4B),
                                            fontWeight = FontWeight.SemiBold
                                        )
                                    }
                                } else {
                                    Text(
                                        text = if (table.isBusy) "Band" else "Bo'sh",
                                        color = if (table.isBusy) Color(0xFF9C3C24) else Color(0xFF2B7A4B),
                                        fontWeight = FontWeight.SemiBold
                                    )
                                }
                            }
                        }
                    }
                    if (rowTables.size == 1) {
                        Spacer(modifier = Modifier.weight(1f))
                    }
                }
            }
        }
    }
}

@Composable
private fun MenuOrderScreen(
    tableId: Int,
    menu: List<MenuItemData>,
    quantities: List<Int>,
    onBack: () -> Unit,
    onIncrease: (Int) -> Unit,
    onDecrease: (Int) -> Unit,
    onSubmitOrder: (List<SubmittedOrderItem>) -> Unit
) {
    val totalItems = quantities.sum()
    val totalPrice = menu.indices.sumOf { index -> menu[index].price * quantities[index] }
    val groupedMenu = menu.withIndex().groupBy { it.value.category }
    var selectedCategory by rememberSaveable { mutableStateOf<String?>(null) }
    val submittedItems = menu.mapIndexedNotNull { index, item ->
        val quantity = quantities[index]
        if (quantity > 0) {
            SubmittedOrderItem(
                name = item.name,
                quantity = quantity,
                imageRes = item.imageRes
            )
        } else {
            null
        }
    }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(20.dp)
    ) {
        HeaderWithAction(
            title = "Stol $tableId buyurtmasi",
            subtitle = "Kategoriyalar bo'yicha taomlarni tanlang",
            actionLabel = "Stollar",
            onAction = onBack
        )
        Spacer(modifier = Modifier.height(16.dp))
        LazyColumn(
            modifier = Modifier.weight(1f),
            verticalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            groupedMenu.forEach { (category, itemsInCategory) ->
                item {
                    Card(
                        modifier = Modifier.clickable {
                            selectedCategory = if (selectedCategory == category) null else category
                        },
                        shape = RoundedCornerShape(20.dp),
                        colors = CardDefaults.cardColors(containerColor = Color(0xFFF1DFCF))
                    ) {
                        Row(
                            modifier = Modifier
                                .fillMaxWidth()
                                .padding(horizontal = 18.dp, vertical = 14.dp),
                            horizontalArrangement = Arrangement.SpaceBetween,
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Text(
                                text = category,
                                style = MaterialTheme.typography.titleLarge,
                                fontWeight = FontWeight.Bold,
                                color = Color(0xFF6B3E26)
                            )
                            Text(
                                text = if (selectedCategory == category) "Yopish" else "Ochish",
                                color = Color(0xFF8A4B2A),
                                fontWeight = FontWeight.SemiBold
                            )
                        }
                    }
                }
                if (selectedCategory == category) {
                    items(itemsInCategory) { indexedItem ->
                        val index = indexedItem.index
                        val item = indexedItem.value
                        Card(
                            shape = RoundedCornerShape(22.dp),
                            colors = CardDefaults.cardColors(containerColor = Color.White)
                        ) {
                            Column(modifier = Modifier.padding(18.dp)) {
                                FoodThumbnail(
                                    title = item.name,
                                    category = item.category,
                                    imageRes = item.imageRes
                                )
                                Spacer(modifier = Modifier.height(12.dp))
                                Text(
                                    text = item.name,
                                    style = MaterialTheme.typography.titleMedium,
                                    fontWeight = FontWeight.Bold
                                )
                                Text(
                                    text = "${item.price} so'm",
                                    color = MaterialTheme.colorScheme.primary
                                )
                                Text(
                                    text = item.description,
                                    modifier = Modifier.padding(top = 6.dp),
                                    color = MaterialTheme.colorScheme.onSurfaceVariant
                                )
                                Spacer(modifier = Modifier.height(12.dp))
                                Row(
                                    modifier = Modifier.fillMaxWidth(),
                                    horizontalArrangement = Arrangement.SpaceBetween,
                                    verticalAlignment = Alignment.CenterVertically
                                ) {
                                    Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                                        OutlinedButton(onClick = { onDecrease(index) }) {
                                            Text("-")
                                        }
                                        Box(
                                            modifier = Modifier
                                                .clip(RoundedCornerShape(14.dp))
                                                .background(Color(0xFFF5E7D6))
                                                .padding(horizontal = 20.dp, vertical = 12.dp)
                                        ) {
                                            Text(
                                                text = quantities[index].toString(),
                                                fontWeight = FontWeight.Bold
                                            )
                                        }
                                        Button(onClick = { onIncrease(index) }) {
                                            Text("+")
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        Card(
            modifier = Modifier
                .fillMaxWidth()
                .padding(top = 16.dp),
            shape = RoundedCornerShape(24.dp),
            colors = CardDefaults.cardColors(containerColor = Color(0xFF2E221C))
        ) {
            Column(
                modifier = Modifier.padding(20.dp),
                verticalArrangement = Arrangement.spacedBy(10.dp)
            ) {
                Text(
                    text = "Jami pozitsiya: $totalItems",
                    color = Color.White
                )
                Text(
                    text = "Jami summa: $totalPrice so'm",
                    color = Color.White,
                    style = MaterialTheme.typography.titleLarge,
                    fontWeight = FontWeight.Bold
                )
                Button(
                    onClick = { onSubmitOrder(submittedItems) },
                    enabled = totalItems > 0,
                    modifier = Modifier.fillMaxWidth()
                ) {
                    Text("Buyurtmani yuborish")
                }
            }
        }
    }
}

private data class SubmittedOrderItem(
    val name: String,
    val quantity: Int,
    val imageRes: Int
)

@Composable
private fun ProfileScreen(
    userLogin: String,
    waiter: WaiterProfile,
    profileImageUri: String?,
    onProfileImageChange: (String?) -> Unit,
    onLogout: () -> Unit
) {
    val context = LocalContext.current
    val profileBitmap = rememberProfileBitmap(profileImageUri)
    val imagePickerLauncher = rememberLauncherForActivityResult(
        contract = ActivityResultContracts.OpenDocument()
    ) { uri ->
        if (uri != null) {
            runCatching {
                context.contentResolver.takePersistableUriPermission(
                    uri,
                    Intent.FLAG_GRANT_READ_URI_PERMISSION
                )
            }
            onProfileImageChange(uri.toString())
        }
    }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .verticalScroll(rememberScrollState())
            .padding(20.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        Card(
            shape = RoundedCornerShape(28.dp),
            colors = CardDefaults.cardColors(containerColor = Color.White)
        ) {
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(24.dp),
                horizontalAlignment = Alignment.CenterHorizontally,
                verticalArrangement = Arrangement.spacedBy(12.dp)
            ) {
                if (profileBitmap != null) {
                    Image(
                        bitmap = profileBitmap,
                        contentDescription = "Ofitsant rasmi",
                        modifier = Modifier
                            .size(124.dp)
                            .clip(CircleShape),
                        contentScale = ContentScale.Crop
                    )
                } else {
                    Image(
                        painter = painterResource(id = R.drawable.waiter_avatar),
                        contentDescription = "Ofitsant rasmi",
                        modifier = Modifier
                            .size(124.dp)
                            .clip(CircleShape),
                        contentScale = ContentScale.Crop
                    )
                }
                Text(
                    text = waiter.name,
                    style = MaterialTheme.typography.headlineSmall,
                    fontWeight = FontWeight.Bold
                )
                Text(
                    text = userLogin,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
                Text(
                    text = waiter.position,
                    color = MaterialTheme.colorScheme.primary
                )
                OutlinedButton(
                    onClick = {
                        imagePickerLauncher.launch(arrayOf("image/*"))
                    }
                ) {
                    Text(if (profileImageUri == null) "Rasm yuklash" else "Rasmni almashtirish")
                }
                Button(
                    onClick = onLogout,
                    modifier = Modifier.fillMaxWidth()
                ) {
                    Text("Akkauntdan chiqish")
                }
            }
        }

        SectionTitle(title = "Shaxsiy ma'lumotlar")
        ProfileInfoCard(label = "Telefon", value = waiter.phone)
        ProfileInfoCard(label = "Smena", value = waiter.shift)
        ProfileInfoCard(label = "Tajriba", value = waiter.experience)
        ProfileInfoCard(label = "Filial", value = "Andijan Restoran, Bobur shoh ko'chasi")
    }
}

@Composable
private fun rememberProfileBitmap(uriString: String?): ImageBitmap? {
    val context = LocalContext.current
    val bitmapState by produceState<ImageBitmap?>(initialValue = null, uriString) {
        value = if (uriString.isNullOrEmpty()) {
            null
        } else {
            runCatching {
                context.contentResolver.openInputStream(Uri.parse(uriString))?.use { stream ->
                    BitmapFactory.decodeStream(stream)?.asImageBitmap()
                }
            }.getOrNull()
        }
    }
    return bitmapState
}

@Composable
private fun DirectorDashboardScreen(
    director: WaiterProfile,
    tables: List<TableInfo>,
    tableAssignments: Map<Int, List<String>>,
    menu: List<MenuItemData>,
    profileImageUris: Map<String, String?>
) {
    val activeTables = tableAssignments.filterValues { it.isNotEmpty() }
    val activeWaiters = activeTables.values.flatten().distinct()
    val freeTables = tables.count { tableAssignments[it.id].isNullOrEmpty() && !it.isBusy }
    val busyTables = activeTables.size + tables.count { it.isBusy && tableAssignments[it.id].isNullOrEmpty() }
    val menuCategories = menu.map { it.category }.distinct().size
    var selectedTableForDetails by rememberSaveable { mutableStateOf<Int?>(null) }

    LazyColumn(
        modifier = Modifier
            .fillMaxSize()
            .padding(20.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        item {
            Card(
                shape = RoundedCornerShape(28.dp),
                colors = CardDefaults.cardColors(containerColor = Color(0xFF263238))
            ) {
                Column(
                    modifier = Modifier.padding(24.dp),
                    verticalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    Text(
                        text = "Direktor paneli",
                        color = Color.White,
                        style = MaterialTheme.typography.headlineSmall,
                        fontWeight = FontWeight.Bold
                    )
                    Text(
                        text = "${director.name} | ${director.position}",
                        color = Color(0xFFD8E5EA)
                    )
                    Text(
                        text = "Restorandagi joriy stol holati va xizmat ko'rsatayotgan ofitsantlar nazorati.",
                        color = Color(0xFFD8E5EA)
                    )
                }
            }
        }
        item {
            Row(horizontalArrangement = Arrangement.spacedBy(12.dp)) {
                SummaryMetricCard(
                    modifier = Modifier.weight(1f),
                    title = "Faol stollar",
                    value = activeTables.size.toString(),
                    accent = Color(0xFFB26A3C)
                )
                SummaryMetricCard(
                    modifier = Modifier.weight(1f),
                    title = "Faol ofitsantlar",
                    value = activeWaiters.size.toString(),
                    accent = Color(0xFF2B7A4B)
                )
            }
        }
        item {
            Row(horizontalArrangement = Arrangement.spacedBy(12.dp)) {
                SummaryMetricCard(
                    modifier = Modifier.weight(1f),
                    title = "Bo'sh stollar",
                    value = freeTables.toString(),
                    accent = Color(0xFF1E88A8)
                )
                SummaryMetricCard(
                    modifier = Modifier.weight(1f),
                    title = "Menyu bo'limlari",
                    value = menuCategories.toString(),
                    accent = Color(0xFF7A4E9C)
                )
            }
        }
        item {
            SectionTitle(title = "Stollar bo'yicha nazorat")
        }
        items(tables.chunked(2)) { tableRow ->
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(12.dp)
            ) {
                tableRow.forEach { table ->
                    val assigned = tableAssignments[table.id].orEmpty()
                    Card(
                        modifier = Modifier
                            .weight(1f)
                            .clickable { selectedTableForDetails = table.id },
                        shape = RoundedCornerShape(22.dp),
                        colors = CardDefaults.cardColors(containerColor = Color.White)
                    ) {
                        Column(
                            modifier = Modifier.padding(18.dp),
                            verticalArrangement = Arrangement.spacedBy(6.dp)
                        ) {
                            Text(
                                text = "Stol ${table.id}",
                                style = MaterialTheme.typography.titleMedium,
                                fontWeight = FontWeight.Bold
                            )
                            Text("${table.seats} kishilik | ${table.location}")
                            Text(
                                text = when {
                                    assigned.isNotEmpty() -> "Xizmat ko'rsatilmoqda"
                                    table.isBusy -> "Band"
                                    else -> "Bo'sh"
                                },
                                color = when {
                                    assigned.isNotEmpty() -> Color(0xFF9C3C24)
                                    table.isBusy -> Color(0xFFB26A3C)
                                    else -> Color(0xFF2B7A4B)
                                },
                                fontWeight = FontWeight.SemiBold
                            )
                            if (assigned.isEmpty()) {
                                Text(
                                    text = "Hozircha xizmat ko'rsatayotgan ofitsant yo'q",
                                    color = MaterialTheme.colorScheme.onSurfaceVariant
                                )
                            } else {
                                assigned.forEach { waiterLogin ->
                                    DirectorWaiterAssignmentRow(
                                        waiterLogin = waiterLogin,
                                        imageUri = profileImageUris[waiterLogin]
                                    )
                                }
                            }
                        }
                    }
                }
                if (tableRow.size == 1) {
                    Spacer(modifier = Modifier.weight(1f))
                }
            }
        }
        item {
            SectionTitle(title = "Qisqa ko'rsatkichlar")
        }
        item {
            Card(
                shape = RoundedCornerShape(22.dp),
                colors = CardDefaults.cardColors(containerColor = Color.White)
            ) {
                Column(
                    modifier = Modifier.padding(18.dp),
                    verticalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    Text("Band yoki xizmatdagi stollar: $busyTables")
                    Text("Nazorat ostidagi jami stol: ${tables.size}")
                    Text("Faol xizmat guruhlari: ${activeTables.values.sumOf { it.distinct().size }}")
                }
            }
        }
    }
    selectedTableForDetails?.let { tableId ->
        val table = tables.firstOrNull { it.id == tableId }
        val assigned = tableAssignments[tableId].orEmpty()
        if (table != null) {
            DirectorTableDetailsDialog(
                table = table,
                activeWaiters = assigned,
                onDismiss = { selectedTableForDetails = null },
                profileImageUris = profileImageUris
            )
        }
    }
}

@Composable
private fun DirectorWaiterAssignmentRow(
    waiterLogin: String,
    imageUri: String?
) {
    val profileBitmap = rememberProfileBitmap(imageUri)
    Row(
        modifier = Modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.spacedBy(10.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        if (profileBitmap != null) {
            Image(
                bitmap = profileBitmap,
                contentDescription = "Ofitsant rasmi",
                modifier = Modifier
                    .size(34.dp)
                    .clip(CircleShape),
                contentScale = ContentScale.Crop
            )
        } else {
            Image(
                painter = painterResource(id = R.drawable.waiter_avatar),
                contentDescription = "Ofitsant rasmi",
                modifier = Modifier
                    .size(34.dp)
                    .clip(CircleShape),
                contentScale = ContentScale.Crop
            )
        }
        Column(verticalArrangement = Arrangement.spacedBy(2.dp)) {
            Text(
                text = waiterNameByLogin(waiterLogin),
                fontWeight = FontWeight.SemiBold
            )
            Text(
                text = waiterLogin,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
        }
    }
}

@Composable
private fun DirectorTableDetailsDialog(
    table: TableInfo,
    activeWaiters: List<String>,
    profileImageUris: Map<String, String?>,
    onDismiss: () -> Unit
) {
    AlertDialog(
        onDismissRequest = onDismiss,
        confirmButton = {
            TextButton(onClick = onDismiss) {
                Text("Yopish")
            }
        },
        title = {
            Text("Stol ${table.id} batafsil ma'lumot")
        },
        text = {
            Column(verticalArrangement = Arrangement.spacedBy(10.dp)) {
                Text("${table.seats} kishilik | ${table.location}")
                Text(
                    text = when {
                        activeWaiters.isNotEmpty() -> "Hozir xizmat ko'rsatilmoqda"
                        table.isBusy -> "Band"
                        else -> "Bo'sh"
                    },
                    fontWeight = FontWeight.SemiBold
                )
                Text("Xizmat ko'rsatayotgan ofitsantlar")
                if (activeWaiters.isEmpty()) {
                    Text(
                        text = "Hozircha faol ofitsant yo'q",
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                } else {
                    activeWaiters.forEach { waiterLogin ->
                        DirectorWaiterAssignmentRow(
                            waiterLogin = waiterLogin,
                            imageUri = profileImageUris[waiterLogin]
                        )
                    }
                }
            }
        }
    )
}

@Composable
private fun DirectorReportsScreen(
    director: WaiterProfile,
    salesReport: SalesReport
) {
    val dailyTotal = salesReport.dailyCash + salesReport.dailyCard

    LazyColumn(
        modifier = Modifier
            .fillMaxSize()
            .padding(20.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        item {
            Card(
                shape = RoundedCornerShape(28.dp),
                colors = CardDefaults.cardColors(containerColor = Color(0xFF1F3A5F))
            ) {
                Column(
                    modifier = Modifier.padding(24.dp),
                    verticalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    Text(
                        text = "Hisobotlar bo'limi",
                        color = Color.White,
                        style = MaterialTheme.typography.headlineSmall,
                        fontWeight = FontWeight.Bold
                    )
                    Text(
                        text = "${director.name} | ${director.position}",
                        color = Color(0xFFD6E4F2)
                    )
                    Text(
                        text = "Kunlik, haftalik va oylik savdo ko'rsatkichlari shu yerda jamlangan.",
                        color = Color(0xFFD6E4F2)
                    )
                }
            }
        }
        item {
            Row(horizontalArrangement = Arrangement.spacedBy(12.dp)) {
                SummaryMetricCard(
                    modifier = Modifier.weight(1f),
                    title = "Kunlik jami",
                    value = "${dailyTotal / 1000}k so'm",
                    accent = Color(0xFF2B7A4B)
                )
                SummaryMetricCard(
                    modifier = Modifier.weight(1f),
                    title = "Buyurtmalar",
                    value = salesReport.dailyOrders.toString(),
                    accent = Color(0xFFB26A3C)
                )
            }
        }
        item {
            Row(horizontalArrangement = Arrangement.spacedBy(12.dp)) {
                SummaryMetricCard(
                    modifier = Modifier.weight(1f),
                    title = "Naqd",
                    value = "${salesReport.dailyCash / 1000}k",
                    accent = Color(0xFF1E88A8)
                )
                SummaryMetricCard(
                    modifier = Modifier.weight(1f),
                    title = "Karta",
                    value = "${salesReport.dailyCard / 1000}k",
                    accent = Color(0xFF7A4E9C)
                )
            }
        }
        item {
            SectionTitle(title = "Eng ko'p sotilgan mahsulotlar")
        }
        items(salesReport.topProducts) { product ->
            Card(
                shape = RoundedCornerShape(22.dp),
                colors = CardDefaults.cardColors(containerColor = Color.White)
            ) {
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(18.dp),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Column(verticalArrangement = Arrangement.spacedBy(4.dp)) {
                        Text(
                            text = product.productName,
                            style = MaterialTheme.typography.titleMedium,
                            fontWeight = FontWeight.Bold
                        )
                        Text(
                            text = "${product.quantity} dona sotilgan",
                            color = MaterialTheme.colorScheme.onSurfaceVariant
                        )
                    }
                    Text(
                        text = "${product.revenue / 1000}k so'm",
                        color = MaterialTheme.colorScheme.primary,
                        fontWeight = FontWeight.SemiBold
                    )
                }
            }
        }
        item {
            SectionTitle(title = "Savdo analizlari")
        }
        item {
            ReportInsightCard(
                title = "Kunlik analiz",
                value = "${dailyTotal / 1000}k so'm",
                subtitle = salesReport.dailyTrend
            )
        }
        item {
            ReportInsightCard(
                title = "Haftalik analiz",
                value = "${salesReport.weeklyRevenue / 1000}k so'm | +${salesReport.weeklyGrowthPercent}%",
                subtitle = salesReport.weeklyTrend
            )
        }
        item {
            ReportInsightCard(
                title = "Oylik analiz",
                value = "${salesReport.monthlyRevenue / 1000}k so'm | +${salesReport.monthlyGrowthPercent}%",
                subtitle = salesReport.monthlyTrend
            )
        }
    }
}

@Composable
private fun DirectorWaitersScreen(
    tableAssignments: Map<Int, List<String>>,
    profileImageUris: Map<String, String?>,
    orderRecords: List<OrderRecord>,
    onRejectOrder: (Int) -> Unit
) {
    val waiterLogins = waiterAccounts
        .filterValues { it.role == UserRole.WAITER }
        .keys
        .sorted()
    var selectedWaiterLogin by rememberSaveable { mutableStateOf<String?>(null) }

    LazyColumn(
        modifier = Modifier
            .fillMaxSize()
            .padding(20.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        item {
            Card(
                shape = RoundedCornerShape(28.dp),
                colors = CardDefaults.cardColors(containerColor = Color(0xFF234A57))
            ) {
                Column(
                    modifier = Modifier.padding(24.dp),
                    verticalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    Text(
                        text = "Ofitsantlar bo'limi",
                        color = Color.White,
                        style = MaterialTheme.typography.headlineSmall,
                        fontWeight = FontWeight.Bold
                    )
                    Text(
                        text = "Har bir ofitsantga biriktirilgan stollar va bugungi buyurtmalarni ko'ring.",
                        color = Color(0xFFD8EDF2)
                    )
                }
            }
        }
        item {
            SectionTitle(title = "Barcha ofitsantlar")
        }
        items(waiterLogins.chunked(2)) { waiterRow ->
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(12.dp)
            ) {
                waiterRow.forEach { waiterLogin ->
                    val profile = waiterAccounts[waiterLogin]?.profile ?: return@forEach
                    val tablesForWaiter = tableAssignments
                        .filterValues { assigned -> assigned.contains(waiterLogin) }
                        .keys
                        .sorted()
                    val activeOrders = orderRecords.count {
                        it.waiterLogin == waiterLogin && it.status == OrderStatus.ACTIVE
                    }
                    val rejectedOrders = orderRecords.count {
                        it.waiterLogin == waiterLogin && it.status == OrderStatus.REJECTED
                    }
                    WaiterOverviewCard(
                        modifier = Modifier.weight(1f),
                        waiterLogin = waiterLogin,
                        waiter = profile,
                        profileImageUri = profileImageUris[waiterLogin],
                        tablesForWaiter = tablesForWaiter,
                        activeOrders = activeOrders,
                        rejectedOrders = rejectedOrders,
                        onClick = { selectedWaiterLogin = waiterLogin }
                    )
                }
                if (waiterRow.size == 1) {
                    Spacer(modifier = Modifier.weight(1f))
                }
            }
        }
    }

    selectedWaiterLogin?.let { waiterLogin ->
        val waiter = waiterAccounts[waiterLogin]?.profile
        if (waiter != null) {
            WaiterOrdersDialog(
                waiterLogin = waiterLogin,
                waiter = waiter,
                profileImageUri = profileImageUris[waiterLogin],
                tablesForWaiter = tableAssignments
                    .filterValues { assigned -> assigned.contains(waiterLogin) }
                    .keys
                    .sorted(),
                orders = orderRecords.filter { it.waiterLogin == waiterLogin },
                onRejectOrder = onRejectOrder,
                onDismiss = { selectedWaiterLogin = null }
            )
        }
    }
}

@Composable
private fun SummaryMetricCard(
    modifier: Modifier = Modifier,
    title: String,
    value: String,
    accent: Color
) {
    Card(
        modifier = modifier,
        shape = RoundedCornerShape(22.dp),
        colors = CardDefaults.cardColors(containerColor = Color.White)
    ) {
        Column(
            modifier = Modifier.padding(18.dp),
            verticalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            Box(
                modifier = Modifier
                    .size(14.dp)
                    .clip(CircleShape)
                    .background(accent)
            )
            Text(text = title, color = MaterialTheme.colorScheme.onSurfaceVariant)
            Text(
                text = value,
                style = MaterialTheme.typography.headlineMedium,
                fontWeight = FontWeight.Bold
            )
        }
    }
}

@Composable
private fun WaiterOverviewCard(
    modifier: Modifier = Modifier,
    waiterLogin: String,
    waiter: WaiterProfile,
    profileImageUri: String?,
    tablesForWaiter: List<Int>,
    activeOrders: Int,
    rejectedOrders: Int,
    onClick: () -> Unit
) {
    val profileBitmap = rememberProfileBitmap(profileImageUri)
    Card(
        modifier = modifier.clickable(onClick = onClick),
        shape = RoundedCornerShape(22.dp),
        colors = CardDefaults.cardColors(containerColor = Color.White)
    ) {
        Column(
            modifier = Modifier.padding(18.dp),
            verticalArrangement = Arrangement.spacedBy(10.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            if (profileBitmap != null) {
                Image(
                    bitmap = profileBitmap,
                    contentDescription = waiter.name,
                    modifier = Modifier
                        .size(78.dp)
                        .clip(CircleShape),
                    contentScale = ContentScale.Crop
                )
            } else {
                Image(
                    painter = painterResource(id = R.drawable.waiter_avatar),
                    contentDescription = waiter.name,
                    modifier = Modifier
                        .size(78.dp)
                        .clip(CircleShape),
                    contentScale = ContentScale.Crop
                )
            }
            Text(
                text = waiter.name,
                style = MaterialTheme.typography.titleMedium,
                fontWeight = FontWeight.Bold,
                textAlign = TextAlign.Center
            )
            Text(
                text = waiterLogin,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
            Text(
                text = if (tablesForWaiter.isEmpty()) {
                    "Hozir stol biriktirilmagan"
                } else {
                    "Qarayotgan stollar: ${tablesForWaiter.joinToString(", ") { "#$it" }}"
                },
                textAlign = TextAlign.Center,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
            Text(
                text = "Bugungi buyurtmalar: $activeOrders",
                color = Color(0xFF2B7A4B),
                fontWeight = FontWeight.SemiBold
            )
            Text(
                text = "Rad etilganlar: $rejectedOrders",
                color = Color(0xFF9C3C24),
                fontWeight = FontWeight.SemiBold
            )
        }
    }
}

@Composable
private fun WaiterOrdersDialog(
    waiterLogin: String,
    waiter: WaiterProfile,
    profileImageUri: String?,
    tablesForWaiter: List<Int>,
    orders: List<OrderRecord>,
    onRejectOrder: (Int) -> Unit,
    onDismiss: () -> Unit
) {
    val activeOrders = orders.filter { it.status == OrderStatus.ACTIVE }
    val rejectedOrders = orders.filter { it.status == OrderStatus.REJECTED }
    val profileBitmap = rememberProfileBitmap(profileImageUri)

    AlertDialog(
        onDismissRequest = onDismiss,
        confirmButton = {
            TextButton(onClick = onDismiss) {
                Text("Yopish")
            }
        },
        title = {
            Row(
                horizontalArrangement = Arrangement.spacedBy(12.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                if (profileBitmap != null) {
                    Image(
                        bitmap = profileBitmap,
                        contentDescription = waiter.name,
                        modifier = Modifier
                            .size(52.dp)
                            .clip(CircleShape),
                        contentScale = ContentScale.Crop
                    )
                } else {
                    Image(
                        painter = painterResource(id = R.drawable.waiter_avatar),
                        contentDescription = waiter.name,
                        modifier = Modifier
                            .size(52.dp)
                            .clip(CircleShape),
                        contentScale = ContentScale.Crop
                    )
                }
                Column {
                    Text(waiter.name)
                    Text(
                        text = waiterLogin,
                        color = MaterialTheme.colorScheme.onSurfaceVariant,
                        style = MaterialTheme.typography.bodyMedium
                    )
                }
            }
        },
        text = {
            Column(
                modifier = Modifier
                    .heightIn(max = 420.dp)
                    .verticalScroll(rememberScrollState()),
                verticalArrangement = Arrangement.spacedBy(14.dp)
            ) {
                Text(
                    text = if (tablesForWaiter.isEmpty()) {
                        "Biriktirilgan stol yo'q"
                    } else {
                        "Qarayotgan stollari: ${tablesForWaiter.joinToString(", ") { "#$it" }}"
                    },
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
                Text(
                    text = "Bugungi olingan buyurtmalar",
                    style = MaterialTheme.typography.titleMedium,
                    fontWeight = FontWeight.Bold
                )
                if (activeOrders.isEmpty()) {
                    Text(
                        text = "Bugun faol buyurtma yo'q",
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                } else {
                    activeOrders.forEach { order ->
                        OrderHistoryCard(
                            order = order,
                            accent = Color(0xFF2B7A4B),
                            actionLabel = "Rad etish",
                            onAction = { onRejectOrder(order.id) }
                        )
                    }
                }
                Text(
                    text = "Rad etilgan buyurtmalar",
                    style = MaterialTheme.typography.titleMedium,
                    fontWeight = FontWeight.Bold
                )
                if (rejectedOrders.isEmpty()) {
                    Text(
                        text = "Rad etilgan buyurtma yo'q",
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                } else {
                    rejectedOrders.forEach { order ->
                        OrderHistoryCard(
                            order = order,
                            accent = Color(0xFF9C3C24)
                        )
                    }
                }
            }
        }
    )
}

@Composable
private fun OrderHistoryCard(
    order: OrderRecord,
    accent: Color,
    actionLabel: String? = null,
    onAction: (() -> Unit)? = null
) {
    Card(
        shape = RoundedCornerShape(20.dp),
        colors = CardDefaults.cardColors(containerColor = Color.White)
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(14.dp),
            horizontalArrangement = Arrangement.spacedBy(12.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            FoodThumbnail(
                title = order.itemName,
                category = "Taom",
                imageRes = order.itemImageRes,
                modifier = Modifier.size(74.dp)
            )
            Column(
                modifier = Modifier.weight(1f),
                verticalArrangement = Arrangement.spacedBy(4.dp)
            ) {
                Text(
                    text = order.itemName,
                    style = MaterialTheme.typography.titleMedium,
                    fontWeight = FontWeight.Bold
                )
                Text("Miqdor: ${order.quantity} dona")
                Text(
                    text = "Stol #${order.tableId}",
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
                Text(
                    text = if (order.status == OrderStatus.ACTIVE) {
                        "Faol buyurtma"
                    } else {
                        "Rad etilgan"
                    },
                    color = accent,
                    fontWeight = FontWeight.SemiBold
                )
            }
        }
        if (actionLabel != null && onAction != null) {
            TextButton(
                onClick = onAction,
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 8.dp, vertical = 4.dp)
            ) {
                Text(actionLabel, color = Color(0xFF9C3C24))
            }
        }
    }
}

@Composable
private fun FoodThumbnail(
    title: String,
    category: String,
    imageRes: Int,
    modifier: Modifier = Modifier
) {
    Card(
        modifier = modifier,
        shape = RoundedCornerShape(18.dp),
        colors = CardDefaults.cardColors(containerColor = foodAccentColor(category))
    ) {
        Box(
            modifier = Modifier.fillMaxSize(),
            contentAlignment = Alignment.Center
        ) {
            Image(
                painter = painterResource(id = imageRes),
                contentDescription = title,
                modifier = Modifier
                    .fillMaxSize()
                    .padding(10.dp),
                contentScale = ContentScale.Fit
            )
        }
    }
}

private fun foodAccentColor(category: String): Color {
    return when (category) {
        "Milliy taomlar" -> Color(0xFFF2D7B5)
        "Turk taomlari" -> Color(0xFFF3D0C7)
        "Fastfoodlar" -> Color(0xFFE6D8F8)
        "Salatlar" -> Color(0xFFD7EEDC)
        "Ichimliklar" -> Color(0xFFD7EBF3)
        "Desertlar" -> Color(0xFFF5DDED)
        else -> Color(0xFFF1E4D7)
    }
}

@Composable
private fun ReportInsightCard(
    title: String,
    value: String,
    subtitle: String
) {
    Card(
        shape = RoundedCornerShape(22.dp),
        colors = CardDefaults.cardColors(containerColor = Color.White)
    ) {
        Column(
            modifier = Modifier.padding(18.dp),
            verticalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            Text(
                text = title,
                style = MaterialTheme.typography.titleMedium,
                fontWeight = FontWeight.Bold
            )
            Text(
                text = value,
                style = MaterialTheme.typography.titleLarge,
                color = MaterialTheme.colorScheme.primary,
                fontWeight = FontWeight.SemiBold
            )
            Text(
                text = subtitle,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
        }
    }
}

@Composable
private fun ProfileInfoCard(label: String, value: String) {
    Card(
        shape = RoundedCornerShape(20.dp),
        colors = CardDefaults.cardColors(containerColor = Color.White)
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(18.dp),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Text(text = label, color = MaterialTheme.colorScheme.onSurfaceVariant)
            Text(text = value, fontWeight = FontWeight.SemiBold, textAlign = TextAlign.End)
        }
    }
}

@Composable
private fun HeaderWithAction(
    title: String,
    subtitle: String,
    actionLabel: String,
    onAction: () -> Unit
) {
    Row(
        modifier = Modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.SpaceBetween,
        verticalAlignment = Alignment.CenterVertically
    ) {
        Column(modifier = Modifier.weight(1f)) {
            Text(
                text = title,
                style = MaterialTheme.typography.headlineSmall,
                fontWeight = FontWeight.Bold
            )
            Text(text = subtitle, color = MaterialTheme.colorScheme.onSurfaceVariant)
        }
        TextButton(onClick = onAction) {
            Text(actionLabel)
        }
    }
}

@Composable
private fun SectionTitle(title: String) {
    Text(
        text = title,
        style = MaterialTheme.typography.titleLarge,
        fontWeight = FontWeight.Bold
    )
}

@Composable
private fun BottomNavigationBar(
    currentSection: MainSection,
    onSectionSelected: (MainSection) -> Unit
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .background(Color.White)
            .padding(horizontal = 16.dp, vertical = 12.dp),
        horizontalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        NavigationChip(
            modifier = Modifier.weight(1f),
            title = "Buyurtma berish",
            selected = currentSection == MainSection.ORDERS,
            onClick = { onSectionSelected(MainSection.ORDERS) }
        )
        NavigationChip(
            modifier = Modifier.weight(1f),
            title = "Profil",
            selected = currentSection == MainSection.PROFILE,
            onClick = { onSectionSelected(MainSection.PROFILE) }
        )
    }
}

@Composable
private fun DirectorBottomBar(
    currentSection: DirectorSection,
    onSectionSelected: (DirectorSection) -> Unit
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .background(Color.White)
            .padding(horizontal = 16.dp, vertical = 12.dp),
        horizontalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        NavigationChip(
            modifier = Modifier.weight(1f),
            title = "Nazorat",
            selected = currentSection == DirectorSection.DASHBOARD,
            onClick = { onSectionSelected(DirectorSection.DASHBOARD) }
        )
        NavigationChip(
            modifier = Modifier.weight(1f),
            title = "Ofitsantlar",
            selected = currentSection == DirectorSection.WAITERS,
            onClick = { onSectionSelected(DirectorSection.WAITERS) }
        )
        NavigationChip(
            modifier = Modifier.weight(1f),
            title = "Hisobotlar",
            selected = currentSection == DirectorSection.REPORTS,
            onClick = { onSectionSelected(DirectorSection.REPORTS) }
        )
        NavigationChip(
            modifier = Modifier.weight(1f),
            title = "Profil",
            selected = currentSection == DirectorSection.PROFILE,
            onClick = { onSectionSelected(DirectorSection.PROFILE) }
        )
    }
}

@Composable
private fun NavigationChip(
    modifier: Modifier = Modifier,
    title: String,
    selected: Boolean,
    onClick: () -> Unit
) {
    Card(
        modifier = modifier.clickable(onClick = onClick),
        shape = RoundedCornerShape(18.dp),
        colors = CardDefaults.cardColors(
            containerColor = if (selected) Color(0xFF8A4B2A) else Color(0xFFF2E7DC)
        )
    ) {
        Text(
            text = title,
            modifier = Modifier
                .fillMaxWidth()
                .padding(vertical = 14.dp),
            textAlign = TextAlign.Center,
            color = if (selected) Color.White else Color(0xFF4B2D1F),
            fontWeight = FontWeight.SemiBold
        )
    }
}

@Preview(showBackground = true)
@Composable
private fun RestaurantAppPreview() {
    AndijanTheme(darkTheme = false, dynamicColor = false) {
        RestaurantApp()
    }
}
