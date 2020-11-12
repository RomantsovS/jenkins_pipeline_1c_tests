#Использовать v8runner
#Использовать cmdline
//#Использовать irac

Перем СЕРВЕР;
Перем СЕРВЕР_СУБД;
Перем БАЗА;
Перем SQL_ПОЛЬЗОВАТЕЛЬ;
Перем SQL_ПАРОЛЬ;
Перем ПЛАТФОРМА_ВЕРСИЯ;
Перем ПУТЬ_К_ФАЙЛУ_БАЗЫ;
Перем ЭТО_СЕРВЕРНАЯ_БАЗА;
Перем ЭТО_RAS;

Перем Лог;
Перем Конфигуратор;

Функция Инициализация()

    Лог = Логирование.ПолучитьЛог("createTeamplateBase");
    Лог.УстановитьУровень(УровниЛога.Отладка);

    Логирование.ПолучитьЛог("oscript.lib.v8runner").УстановитьУровень(Лог.Уровень());

    Парсер = Новый ПарсерАргументовКоманднойСтроки();
    Парсер.ДобавитьИменованныйПараметр("-platform");
    Парсер.ДобавитьИменованныйПараметр("-server1c");
    Парсер.ДобавитьИменованныйПараметр("-serversql");
    Парсер.ДобавитьИменованныйПараметр("-base");
    Парсер.ДобавитьИменованныйПараметр("-sqlpassw");
    Парсер.ДобавитьИменованныйПараметр("-sqluser");
    Парсер.ДобавитьИменованныйПараметр("-cfdt");
    Парсер.ДобавитьИменованныйПараметр("-isras");

    Параметры = Парсер.Разобрать(АргументыКоманднойСтроки);

    ПЛАТФОРМА_ВЕРСИЯ = Параметры["-platform"];
    СЕРВЕР           = Параметры["-server1c"];
    СЕРВЕР_СУБД      = Параметры["-serversql"];
    БАЗА             = Параметры["-base"];
    SQL_ПОЛЬЗОВАТЕЛЬ = Параметры["-sqluser"];
    Если Не ЗначениеЗаполнено(SQL_ПОЛЬЗОВАТЕЛЬ) Тогда
        SQL_ПОЛЬЗОВАТЕЛЬ = ""
    КонецЕсли;
    Если Не ЗначениеЗаполнено(SQL_ПАРОЛЬ) Тогда
        SQL_ПАРОЛЬ = "";
    КонецЕсли;

    ПУТЬ_К_ФАЙЛУ_БАЗЫ = Параметры["-cfdt"];
    Если Не ЗначениеЗаполнено(ПУТЬ_К_ФАЙЛУ_БАЗЫ) Тогда
        ПУТЬ_К_ФАЙЛУ_БАЗЫ = "";
    КонецЕсли;

    ЭТО_RAS = ЗначениеЗаполнено(Параметры["-isras"]);

    //ПЛАТФОРМА_ВЕРСИЯ = "8.3.14.1630";
    //СЕРВЕР           = "localhost:1551";
    //СЕРВЕР_СУБД      = "localhost";
    //БАЗА             = "test_Temp";
    //SQL_ПОЛЬЗОВАТЕЛЬ = "sa";
    //SQL_ПАРОЛЬ = "Kentdfu!1";
    //ЭТО_RAS = Ложь;

    ЭТО_СЕРВЕРНАЯ_БАЗА = ЗначениеЗаполнено(СЕРВЕР);

    Если ЭТО_RAS Тогда
        Конфигуратор = Новый АдминистрированиеКластера(СЕРВЕР, 1545, ПЛАТФОРМА_ВЕРСИЯ);
    Иначе
        Конфигуратор = Новый УправлениеКонфигуратором();
        Если ЗначениеЗаполнено(ПЛАТФОРМА_ВЕРСИЯ) Тогда
            Конфигуратор.ИспользоватьВерсиюПлатформы(ПЛАТФОРМА_ВЕРСИЯ);
        КонецЕсли;
    КонецЕсли;

КонецФункции

Функция СоздатьСервернуюБазу1С()

    ПараметрыБазы1С = Новый Структура;
    ПараметрыБазы1С.Вставить("Сервер1С", СЕРВЕР);
    ПараметрыБазы1С.Вставить("ИмяИБ", БАЗА);

    ПараметрыСУБД = Новый Структура();
    ПараметрыСУБД.Вставить("ТипСУБД", "MSSQLServer");
    ПараметрыСУБД.Вставить("СерверСУБД", СЕРВЕР_СУБД);
    ПараметрыСУБД.Вставить("ПользовательСУБД", SQL_ПОЛЬЗОВАТЕЛЬ);
    ПараметрыСУБД.Вставить("ПарольСУБД", SQL_ПАРОЛЬ);
    ПараметрыСУБД.Вставить("ИмяБД", БАЗА);
    ПараметрыСУБД.Вставить("СоздаватьБД", Истина);

    АвторизацияВКластере = Новый Структура;
    АвторизацияВКластере.Вставить("Имя", "");
    АвторизацияВКластере.Вставить("Пароль", "");
    
    Конфигуратор.СоздатьСервернуюБазу(ПараметрыБазы1С, ПараметрыСУБД, АвторизацияВКластере, Ложь, ПУТЬ_К_ФАЙЛУ_БАЗЫ);

КонецФункции

Процедура СоздатьСервернуюБазуRAS()
    
    Кластеры = Конфигуратор.Кластеры();
    // Обходим список кластеров
    Для Каждого Кластер Из Кластеры.Список() Цикл
        ЛОГ.Информация("Cluster name = " + Кластер.Получить("Имя"));
        ИБКластера = Кластер.ИнформационныеБазы();

        ПараметрыИБ = Новый Структура;
        ПараметрыИБ.Вставить("ТипСУБД", "MSSQLServer");
        ПараметрыИБ.Вставить("АдресСервераСУБД", СЕРВЕР);
        ПараметрыИБ.Вставить("ИмяБазыСУБД", БАЗА);
        ПараметрыИБ.Вставить("ИмяПользователяБазыСУБД", SQL_ПОЛЬЗОВАТЕЛЬ);
        ПараметрыИБ.Вставить("ПарольПользователяБазыСУБД", SQL_ПАРОЛЬ);
        ПараметрыИБ.Вставить("БлокировкаРегламентныхЗаданийВключена", "on");
        ПараметрыИБ.Вставить("ВыдачаЛицензийСервером", "allow");

        ИБКластера.Добавить(БАЗА, , , ПараметрыИБ)
    КонецЦикла;

КонецПроцедуры

Процедура СоздатьФайловуюБазу1С()
    Конфигуратор.СоздатьФайловуюБазу(БАЗА, ПУТЬ_К_ФАЙЛУ_БАЗЫ);
КонецПроцедуры

Процедура СоздатьФайловуюБазуRAS()
    ВызватьИсключение "Not implemented"
КонецПроцедуры

Инициализация();

Если ЭТО_СЕРВЕРНАЯ_БАЗА Тогда
    Если ЭТО_RAS Тогда
        Лог.Информация("Creating server base with RAS...");
        СоздатьСервернуюБазуRAS();
    Иначе
        Лог.Информация("Creating server base with 1C...");
        СоздатьСервернуюБазу1С();
    КонецЕсли;
Иначе
    Если ЭТО_RAS Тогда
        Лог.Информация("Creating file base with RAS...");
        СоздатьФайловуюБазуRAS();
    Иначе
        Лог.Информация("Creating file base with 1C...");
        СоздатьФайловуюБазу1С();
    КонецЕсли;
КонецЕсли;

Лог.Информация("script completed");