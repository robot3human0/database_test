# Тестовый репозиторий
## Тестирую базу данных, а точнее инструменты для отрисовки схемы.

Для тестирования взят скрипт базы данных, из школьного проекта Info21.

### Что выявленно на данный момент:
* Инструмент schemaspy, работает, делает отчет в формате HTML, результат работы этой утилиты можно найти в папке "schemaspy" файл "index.html"
* Пока по прежнему не понимаю, можно ли это как то делать автоматически при каждом пуше измененний базы данных в репозиторий.
  Наверняка это возможно какими нибудь инструментами CI/CD.
* DataGrip имеет собственный инструмент для экспорта диаграммы вашей базы данных, экспорт в различные форматы такие как svg, PNG, спецефические форматы файлов .uml, 
  .md, .gpraphml, а так же зашарить схему в различные онлайн сервисы для отрисовки, типа уже знакомых нам draw.io, diagrams.net и т.д.

Ниже пример экспорта в png
![datagripEportFile](./pics/postgres@localhost.png)

### Note

К стати во время работы утилиты schemaspy у меня вылазили ошибки по типу -целевой контент слишком мал для отображения, если что ниже скрин с ошибками, но тем не менее свою работу утилита исполняет и как упоминалось выше лежит в одноименной папке schemaspy.
![errorsScreenshot](./pics/Screenshot.png)


### Установка и использование schemaspy

* Для работы у нас должна быть установлена java-8 и выше, или open-jdk-1.8 и выше.
  Сижу под Linux с версией не заморачивался просто скачал посредством терминала.
  ```sudo apt install openjdk-8-jre```
* Так же нужно скачать JDBC драйвер для вашей БД, ну у меня это PostgreSQL.
  взял это из документации к schemaspy
  ```
  curl -L https://jdbc.postgresql.org/download/postgresql-42.5.4.jar \
  --output ~/Downloads/jdbc-driver.jar
  ```
* Скачал саму программу schemaspy из репозитория, можно так же скачать докер, я не пробовал, не силен в докере.
  ```
  curl -L https://github.com/schemaspy/schemaspy/releases/download/v6.2.4/schemaspy-6.2.4.jar \
  --output ~/Downloads/schemaspy.jar
  ```
* Еще в документации сказанно что для работы нужен viz.js или Graphviz, но в репозитории написанно что в новых релизах уже не 
  требуется, один из этих интсрументов интегрировали.

### Далее запуск приложения.
* Где находится программа, драйвер JDBC, и собственно сама база НЕ ВАЖНО. В скрипте нужно будет прописать абсолютные пути.
  Собственно ниже пример скрипта из документации.
  ```
  java -jar ~/Downloads/schemaspy.jar \
    -t pgsql11 \
    -dp ~/Downloads/jdbc-driver.jar \
    -db DATABASE \
    -host SERVER \
    -port 5432 \
    -u USER \
    -p PASSWORD \
    -o DIRECTORY
  ```
* А так выглядит мой:
  ```
  # Тип БД
  schemaspy.t=pgsql11
  # Путь до драйвера 
  schemaspy.dp=/home/sidharta/Downloads/jdbc-driver.jar
  # БД настройки:
  # хост
  schemaspy.host=localhost
  # порт
  schemaspy.port=5432
  # Имя моей БД
  schemaspy.db=test
  # юзернэйм
  schemaspy.u=sidharta
  # Тут пароль был мой
  schemaspy.p=*******
  # Путь до папки в которую положить результат работы утилиты.
  schemaspy.o=/home/sidharta/projects/s21-world-test/schemaspy/
  ```
* Сам скрипт положил в директорию вместе с самой программой schemaspy. Запустил такой строчкой тоже взято из доков.
  ```
  java -jar schemaspy-6.2.4.jar -debug -configFile ./config
  ```
* Далее проходим в ту папку которую указали для выходного контента и запускаем index.html

### P.S:
* В эту for_work папку положил: драйвер, скрипт и саму schemaspy. Для работы останется скачать java если не имеется.