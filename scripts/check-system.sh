echo "=== Проверка системы ==="
echo ""
echo "---Load average---"
uptime
echo ""
echo "---Диск---"
df -h /
echo ""
echo "---Память---"
free -h
echo ""
echo "---Топ-5 процессов по CPU---"
ps aux --sort -%cpu | head -6
echo ""
echo "---Слушающие порты---"
sudo ss -tulpn | head -10
