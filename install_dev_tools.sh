#!/bin/bash

# Обновляем списки пакетов Ubuntu перед установкой
echo "Оновлення списків пакетів..."
sudo apt-get update -y

# 1. Перевірка та встановлення Docker
if command -v docker &> /dev/null; then
    echo "Docker вже встановлено: $(docker --version)"
else
    echo "Docker не знайдено. Починаємо встановлення..."
    sudo apt-get install -y docker.io
    sudo systemctl start docker
    sudo systemctl enable docker
fi

# 2. Перевірка та встановлення Docker Compose
if command -v docker-compose &> /dev/null; then
    echo "Docker Compose вже встановлено: $(docker-compose --version)"
else
    echo "Docker Compose не знайдено. Починаємо встановлення..."
    sudo apt-get install -y docker-compose
fi

# 3. Перевірка та встановлення Python 3.9+
if command -v python3 &> /dev/null; then
    PYTHON_VERSION=$(python3 -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')
    # Перевіряємо, чи версія 3.9 або новіша
    if [ "$(echo "$PYTHON_VERSION >= 3.9" | bc 2>/dev/null)" ] || [ "${PYTHON_VERSION#3.}" -ge 9 ]; then
        echo "Python вже встановлено (версія $PYTHON_VERSION), що задовольняє вимогам."
    else
        echo "Встановлено застарілу версію Python ($PYTHON_VERSION). Оновлюємо..."
        sudo apt-get install -y python3
    fi
else
    echo "Python3 не знайдено. Починаємо встановлення..."
    sudo apt-get install -y python3 python3-pip
fi

# 4. Перевірка та встановлення Django через pip
if python3 -c "import django" &> /dev/null; then
    echo "Django вже встановлено: $(python3 -m django --version)"
else
    echo "Django не знайдено. Встановлюємо через pip..."
    # Про всяк випадок встановлюємо pip, якщо його немає
    sudo apt-get install -y python3-pip
    pip3 install django
fi

echo "=== Всі перевірки та встановлення завершено! ==="

