# Script de débogage pour l'API d'assiduité
# Ce script permet de tester les endpoints d'assiduité du backend

Write-Host "🔍 Test de l'API d'assiduité Keep-Tex" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green

# Test 1: Vérifier si le backend tourne
Write-Host "`n1. Test de connexion au backend..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:5000" -Method GET -UseBasicParsing
    Write-Host "✅ Backend accessible (Status: $($response.StatusCode))" -ForegroundColor Green
} catch {
    Write-Host "❌ Backend inaccessible: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Test 2: Vérifier les routes disponibles
Write-Host "`n2. Vérification des routes d'assiduité..." -ForegroundColor Yellow

$routes = @(
    "/api/attendance",
    "/api/users/1/attendance",
    "/api/users/1/mark-present",
    "/api/users/1/mark-absent"
)

foreach ($route in $routes) {
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:5000$route" -Method GET -UseBasicParsing -ErrorAction SilentlyContinue
        Write-Host "✅ $route - $($response.StatusCode)" -ForegroundColor Green
    } catch {
        $statusCode = $_.Exception.Response.StatusCode.value__
        if ($statusCode -eq 401) {
            Write-Host "⚠️  $route - 401 (Auth requise - route existe)" -ForegroundColor Yellow
        } elseif ($statusCode -eq 404) {
            Write-Host "❌ $route - 404 (Route introuvable)" -ForegroundColor Red
        } else {
            Write-Host "❓ $route - Erreur: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}

# Test 3: Tester POST /api/attendance sans authentification
Write-Host "`n3. Test POST /api/attendance..." -ForegroundColor Yellow
$body = @{
    employee_id = "1"
    date = "2024-12-20"
    status = "Présent"
} | ConvertTo-Json

try {
    $response = Invoke-WebRequest -Uri "http://localhost:5000/api/attendance" -Method POST -Body $body -ContentType "application/json" -UseBasicParsing
    Write-Host "✅ POST réussi: $($response.StatusCode)" -ForegroundColor Green
} catch {
    $statusCode = $_.Exception.Response.StatusCode.value__
    $errorContent = $_.ErrorDetails.Message
    Write-Host "❌ POST échoué: $statusCode" -ForegroundColor Red
    Write-Host "Réponse: $errorContent" -ForegroundColor Red
}

Write-Host "`n🔧 Recommandations:" -ForegroundColor Cyan
Write-Host "- Vérifiez que le token JWT est bien envoyé dans le header Authorization" -ForegroundColor Cyan
Write-Host "- Vérifiez le format de la date (YYYY-MM-DD)" -ForegroundColor Cyan
Write-Host "- Vérifiez que l'employee_id existe dans la base de données" -ForegroundColor Cyan
Write-Host "- Consultez les logs du backend pour plus de détails" -ForegroundColor Cyan