# Script de débogage pour l'erreur 500 lors de la création/mise à jour de présence

Write-Host "🔍 Débogage de l'erreur 500 - Création/Mise à jour de présence" -ForegroundColor Yellow
Write-Host "=" * 60

# 1. Vérifier que le backend tourne
Write-Host "`n1. Vérification du backend..." -ForegroundColor Green
try {
    $response = Invoke-RestMethod -Uri "http://localhost:5000/" -Method GET
    Write-Host "✅ Backend accessible: $($response -replace '[\r\n]', '')" -ForegroundColor Green
} catch {
    Write-Host "❌ Backend inaccessible - Vérifiez que le serveur tourne sur localhost:5000" -ForegroundColor Red
    exit 1
}

# 2. Tester l'endpoint GET /api/attendance (nécessite authentification)
Write-Host "`n2. Test de l'endpoint GET /api/attendance..." -ForegroundColor Green
try {
    $response = Invoke-RestMethod -Uri "http://localhost:5000/api/attendance?date=2024-01-15" -Method GET -Headers @{"Authorization"="Bearer test_token"} -ErrorAction SilentlyContinue
    Write-Host "✅ Endpoint GET /api/attendance accessible" -ForegroundColor Green
} catch {
    $status = $_.Exception.Response.StatusCode.value__
    if ($status -eq 401) {
        Write-Host "⚠️  Endpoint nécessite authentification (401) - C'est normal" -ForegroundColor Yellow
    } elseif ($status -eq 404) {
        Write-Host "❌ Endpoint GET /api/attendance non trouvé (404)" -ForegroundColor Red
        Write-Host "💡 Le backend doit avoir cette route implémentée" -ForegroundColor Cyan
    } else {
        Write-Host "❌ Erreur inattendue: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# 3. Tester l'endpoint POST /api/attendance avec authentification simulée
Write-Host "`n3. Test de l'endpoint POST /api/attendance..." -ForegroundColor Green

# Données de test
$testData = @{
    employee_id = "test_employee_123"
    date = "2024-01-15"
    status = "Présent"
} | ConvertTo-Json

Write-Host "Données envoyées: $testData" -ForegroundColor Cyan

try {
    $response = Invoke-RestMethod -Uri "http://localhost:5000/api/attendance" -Method POST -Headers @{
        "Authorization"="Bearer test_token"
        "Content-Type"="application/json"
    } -Body $testData -ErrorAction SilentlyContinue
    
    Write-Host "✅ POST réussi" -ForegroundColor Green
    Write-Host "Réponse: $($response | ConvertTo-Json -Depth 10)" -ForegroundColor Green
} catch {
    $status = $_.Exception.Response.StatusCode.value__
    $errorContent = $_.ErrorDetails.Message
    
    if ($status -eq 500) {
        Write-Host "❌ Erreur 500 détectée - Problème côté serveur" -ForegroundColor Red
        Write-Host "Détails: $errorContent" -ForegroundColor Red
        
        # Essayer d'extraire le message d'erreur
        try {
            $errorJson = $errorContent | ConvertFrom-Json
            Write-Host "Message d'erreur: $($errorJson.error)" -ForegroundColor Red
        } catch {
            Write-Host "Impossible de parser l'erreur JSON" -ForegroundColor Yellow
        }
    } elseif ($status -eq 401) {
        Write-Host "⚠️  Authentification requise (401)" -ForegroundColor Yellow
    } elseif ($status -eq 404) {
        Write-Host "❌ Endpoint POST /api/attendance non trouvé (404)" -ForegroundColor Red
        Write-Host "💡 Le backend doit avoir cette route implémentée" -ForegroundColor Cyan
    } else {
        Write-Host "❌ Erreur: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# 4. Vérifier les routes attendues par le frontend
Write-Host "`n4. Routes attendues par le frontend:" -ForegroundColor Green
Write-Host "   - POST /api/attendance (pour créer/mettre à jour la présence)" -ForegroundColor Cyan
Write-Host "   - GET /api/attendance?date=YYYY-MM-DD (pour récupérer les présences par date)" -ForegroundColor Cyan
Write-Host "   - GET /users/:id/attendance (pour l'historique d'un employé)" -ForegroundColor Cyan

# 5. Recommandations
Write-Host "`n5. Recommandations pour résoudre l'erreur 500:" -ForegroundColor Yellow
Write-Host "   1. Vérifiez que le backend a les routes d'attendance implémentées" -ForegroundColor White
Write-Host "   2. Vérifiez que la base de données a la table 'attendances'" -ForegroundColor White
Write-Host "   3. Vérifiez les logs du backend pour plus de détails" -ForegroundColor White
Write-Host "   4. Assurez-vous que le format des données envoyées correspond à l'attendu" -ForegroundColor White

Write-Host "`n🔍 Fin du script de débogage" -ForegroundColor Yellow