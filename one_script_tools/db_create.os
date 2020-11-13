#Использовать v8runner
#Использовать cmdline
#Использовать irac

Перем СЕРВЕР;
Перем ИМЯ_КЛАСТЕРА;
Перем СЕРВЕР_СУБД;
Перем ИМЯ_БАЗЫ;
Перем SQL_ПОЛЬЗОВАТЕЛЬ;
Перем SQL_ПАРОЛЬ;
Перем ПЛАТФОРМА_ВЕРСИЯ;
Перем RAC_PATH;
Перем RAC_PORT;
Перем Лог;

Перем ЭТО_RAS;
Перем ПУТЬ_К_ФАЙЛУ_БАЗЫ;
Перем ЭТО_СЕРВЕРНАЯ_БАЗА;
Перем ПОРТ_КЛАСТЕРА;

Функция Инициализация()

    Лог = Логирование.ПолучитьЛог("createTeamplateBase");
    Лог.УстановитьУровень(УровниЛога.Отладка);

    Парсер = Новый ПарсерАргументовКоманднойСтроки();
    Парсер.ДобавитьИменованныйПараметр("-platform");
    Парсер.ДобавитьИменованныйПараметр("-server1c");
    Парсер.ДобавитьИменованныйПараметр("-serversql");
    Парсер.ДобавитьИменованныйПараметр("-base_name");
    Парсер.ДобавитьИменованныйПараметр("-sqlpassw");
    Парсер.ДобавитьИменованныйПараметр("-sqluser");
    Парсер.ДобавитьИменованныйПараметр("-rac_path");
    Парсер.ДобавитьИменованныйПараметр("-rac_port");
    Парсер.ДобавитьИменованныйПараметр("-verbose");

    Парсер.ДобавитьИменованныйПараметр("-cfdt");
    Парсер.ДобавитьИменованныйПараметр("-isras");
    Парсер.ДобавитьИменованныйПараметр("-cluster1c_port");

    Параметры = Парсер.Разобрать(АргументыКоманднойСтроки);

    ПЛАТФОРМА_ВЕРСИЯ = Параметры["-platform"];
    СЕРВЕР           = Параметры["-server1c"];
    ИМЯ_КЛАСТЕРА     = Параметры["-cluster1c_name"];
    СЕРВЕР_СУБД      = Параметры["-serversql"];
    ИМЯ_Б            = Параметры["-base"];
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
    RAC_PATH = Параметры["-rac_path"];
    RAC_PORT = Параметры["-rac_port"];

    Если Не ЗначениеЗаполнено(RAC_PORT) Тогда
        RAC_PORT = 1545;
    КонецЕсли;

    ПОРТ_КЛАСТЕРА = Параметры["-cluster1c_port"];
    Если Не ЗначениеЗаполнено(ПОРТ_КЛАСТЕРА) Тогда
        ПОРТ_КЛАСТЕРА = 1545;
    КонецЕсли;
    

    verbose = Параметры["-verbose"];
    Если ЗначениеЗаполнено(verbose) И verbose = "1" Тогда
        Лог.УстановитьУровень(УровниЛога.Отладка);

        Для Каждого СтрПар Из Параметры Цикл
            Лог.Отладка(СтрПар.Ключ + "-" + СтрПар.Значение);
        КонецЦикла;
    КонецЕсли;

    //ПЛАТФОРМА_ВЕРСИЯ = "8.3.14.1630";
    //СЕРВЕР           = "localhost:1551";
    //СЕРВЕР_СУБД      = "localhost";
    //БАЗА             = "test_Temp";
    //SQL_ПОЛЬЗОВАТЕЛЬ = "sa";
    //SQL_ПАРОЛЬ = "Kentdfu!1";
    //ЭТО_RAS = Ложь;

    ЭТО_СЕРВЕРНАЯ_БАЗА = ЗначениеЗаполнено(СЕРВЕР);

    Логирование.ПолучитьЛог("oscript.lib.v8runner").УстановитьУровень(Лог.Уровень());

КонецФункции

Функция СоздатьСервернуюБазу1С()

    Конфигуратор = Новый УправлениеКонфигуратором();
    Если ЗначениеЗаполнено(ПЛАТФОРМА_ВЕРСИЯ) Тогда
        Конфигуратор.ИспользоватьВерсиюПлатформы(ПЛАТФОРМА_ВЕРСИЯ);
    КонецЕсли;

    ПараметрыБазы1С = Новый Структура;
    ПараметрыБазы1С.Вставить("Сервер1С", СтрШаблон("%1:%2", СЕРВЕР, ПОРТ_КЛАСТЕРА));
    ПараметрыБазы1С.Вставить("ИмяИБ", ИМЯ_БАЗЫ);

    ПараметрыСУБД = Новый Структура();
    ПараметрыСУБД.Вставить("ТипСУБД", "MSSQLServer");
    ПараметрыСУБД.Вставить("СерверСУБД", СЕРВЕР_СУБД);
    ПараметрыСУБД.Вставить("ПользовательСУБД", SQL_ПОЛЬЗОВАТЕЛЬ);
    ПараметрыСУБД.Вставить("ПарольСУБД", SQL_ПАРОЛЬ);
    ПараметрыСУБД.Вставить("ИмяБД", ИМЯ_БАЗЫ);
    ПараметрыСУБД.Вставить("СоздаватьБД", Истина);

    АвторизацияВКластере = Новый Структура;
    АвторизацияВКластере.Вставить("Имя", "");
    АвторизацияВКластере.Вставить("Пароль", "");
    
    Конфигуратор.СоздатьСервернуюБазу(ПараметрыБазы1С, ПараметрыСУБД, АвторизацияВКластере, Истина, ПУТЬ_К_ФАЙЛУ_БАЗЫ);

КонецФункции

Процедура СоздатьСервернуюБазуRAS()
    
    Лог.Отладка(RAC_PATH);

    СтрокаПодключения = СтрШаблон("%1:%2", СЕРВЕР, RAC_PORT);
    Лог.Отладка("СтрокаПодключения " + СтрокаПодключения);

    Админка = Новый УправлениеКластером1С(RAC_PATH, СтрокаПодключения, ПЛАТФОРМА_ВЕРСИЯ);

    Кластеры = Админка.Кластеры();
    
    ОтборКластеров = Новый Соответствие();
    ОтборКластеров.Вставить("Имя", СтрШаблон("""%1""", ИМЯ_КЛАСТЕРА)); //в отборе имя кластера возвращается в кавычках

    СписокКластеров = Кластеры.Список(ОтборКластеров);

    Лог.Отладка("Количество кластеров " + СписокКластеров.Количество());

    Если СписокКластеров.Количество() <> 1 Тогда
        ТекстИсключения = СтрШаблон("Найдено %1 кластеров по отбору ", СписокКластеров.Количество());
        Для Каждого СтрокаОтбора Из ОтборКластеров Цикл
            ТекстИсключения = ТекстИсключения + Символы.ПС + СтрокаОтбора.Ключ + "-" + СтрокаОтбора.Значение;
        КонецЦикла;

        ВызватьИсключение ТекстИсключения;
    КонецЕсли;

    // Обходим список кластеров
    Для Каждого Кластер Из СписокКластеров Цикл
        Лог.Информация("Cluster name = " + Кластер.Получить("Имя"));
        
        ИБКластера = Кластер.ИнформационныеБазы();

        ПараметрыИБ = Новый Структура;
        ПараметрыИБ.Вставить("ТипСУБД", "MSSQLServer");
        ПараметрыИБ.Вставить("АдресСервераСУБД", СЕРВЕР);
        ПараметрыИБ.Вставить("ИмяБазыСУБД", ИМЯ_БАЗЫ);
        ПараметрыИБ.Вставить("ИмяПользователяБазыСУБД", SQL_ПОЛЬЗОВАТЕЛЬ);
        ПараметрыИБ.Вставить("ПарольПользователяБазыСУБД", SQL_ПАРОЛЬ);
        ПараметрыИБ.Вставить("БлокировкаРегламентныхЗаданийВключена", "on");
        ПараметрыИБ.Вставить("ВыдачаЛицензийСервером", "allow");

        ИБКластера.Добавить(ИМЯ_БАЗЫ, , Истина, ПараметрыИБ)
    КонецЦикла;

КонецПроцедуры

Процедура СоздатьФайловуюБазу1С()
    Конфигуратор = Новый УправлениеКонфигуратором();
    Если ЗначениеЗаполнено(ПЛАТФОРМА_ВЕРСИЯ) Тогда
        Конфигуратор.ИспользоватьВерсиюПлатформы(ПЛАТФОРМА_ВЕРСИЯ);
    КонецЕсли;
    
    Конфигуратор.СоздатьФайловуюБазу(ИМЯ_БАЗЫ, ПУТЬ_К_ФАЙЛУ_БАЗЫ);
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