#Использовать v8runner
#Использовать cmdline
#Использовать irac

Перем СЕРВЕР;
Перем ИМЯ_КЛАСТЕРА;
Перем СЕРВЕР_СУБД;
Перем ИМЯ_БАЗЫ;
Перем ПЛАТФОРМА_ВЕРСИЯ;
Перем RAC_PATH;
Перем RAC_PORT;
Перем Лог;

Перем ПУТЬ_К_ФАЙЛУ_БАЗЫ;
Перем ЭТО_СЕРВЕРНАЯ_БАЗА;
Перем ПОРТ_КЛАСТЕРА;
Перем АДМИН_1С_ИМЯ;
Перем АДМИН_1С_ПАРОЛЬ;

Перем КОМ_КОННЕКТОР;
Перем ОжидатьВыполнениеОтложенныхОбработчиков;

Перем COMОбъект;

Процедура Инициализация()
    
    Лог = Логирование.ПолучитьЛог("runIBReleaseUpdate");
    
    Парсер = Новый ПарсерАргументовКоманднойСтроки();
    Парсер.ДобавитьИменованныйПараметр("-platform");
    Парсер.ДобавитьИменованныйПараметр("-server1c");
    Парсер.ДобавитьИменованныйПараметр("-cluster1c_port");
    Парсер.ДобавитьИменованныйПараметр("-base_name");
    Парсер.ДобавитьИменованныйПараметр("-admin_1c_name");
    Парсер.ДобавитьИменованныйПараметр("-admin_1c_pwd");
    Парсер.ДобавитьИменованныйПараметр("-rac_path");
    Парсер.ДобавитьИменованныйПараметр("-rac_port");
    Парсер.ДобавитьИменованныйПараметр("-cluster1c_name");
    Парсер.ДобавитьИменованныйПараметр("-wait_deferred_handler");
    Парсер.ДобавитьИменованныйПараметр("-verbose");
    
    Параметры = Парсер.Разобрать(АргументыКоманднойСтроки);
    
    ПЛАТФОРМА_ВЕРСИЯ = Параметры["-platform"];
    СЕРВЕР = Параметры["-server1c"];
    ИМЯ_КЛАСТЕРА = Параметры["-cluster1c_name"];
    ИМЯ_БАЗЫ = Параметры["-base_name"];
    
    АДМИН_1С_ИМЯ = Параметры["-admin_1c_name"];
    Если Не ЗначениеЗаполнено(АДМИН_1С_ИМЯ) Тогда
        АДМИН_1С_ИМЯ = "";
    КонецЕсли;
    АДМИН_1С_ПАРОЛЬ = Параметры["-admin_1c_pwd"];
    Если Не ЗначениеЗаполнено(АДМИН_1С_ПАРОЛЬ) Тогда
        АДМИН_1С_ПАРОЛЬ = "";
    КонецЕсли;
    
    RAC_PATH = Параметры["-rac_path"];
    RAC_PORT = Параметры["-rac_port"];
    
    Если Не ЗначениеЗаполнено(RAC_PATH) Тогда
        RAC_PATH = "localhost";
    КонецЕсли;
    
    Если Не ЗначениеЗаполнено(RAC_PORT) Тогда
        RAC_PORT = 1545;
    КонецЕсли;
    
    ПОРТ_КЛАСТЕРА = Параметры["-cluster1c_port"];
    Если Не ЗначениеЗаполнено(ПОРТ_КЛАСТЕРА) Тогда
        ПОРТ_КЛАСТЕРА = 1545;
    КонецЕсли;
    
    ОжидатьВыполнениеОтложенныхОбработчиков = Параметры["-wait_deferred_handler"];
    Если ЗначениеЗаполнено(ОжидатьВыполнениеОтложенныхОбработчиков) И
        ОжидатьВыполнениеОтложенныхОбработчиков = "1" Тогда
        ОжидатьВыполнениеОтложенныхОбработчиков = Истина;
    Иначе
        ОжидатьВыполнениеОтложенныхОбработчиков = Ложь;
    КонецЕсли;
    
    verbose = Параметры["-verbose"];
    Если ЗначениеЗаполнено(verbose) И verbose = "1" Тогда
        Лог.УстановитьУровень(УровниЛога.Отладка);
        
        Для Каждого СтрПар Из Параметры Цикл
            Лог.Отладка(СтрПар.Ключ + "-" + СтрПар.Значение);
        КонецЦикла;
    КонецЕсли;
    
    КОМ_КОННЕКТОР = "V83.COMConnector";
    
    //ПЛАТФОРМА_ВЕРСИЯ = "8.3.14.1630";
    //СЕРВЕР           = "localhost:1551";
    //БАЗА             = "test_Temp";
    
    ЭТО_СЕРВЕРНАЯ_БАЗА = ЗначениеЗаполнено(СЕРВЕР);
    
    Логирование.ПолучитьЛог("oscript.lib.v8runner").УстановитьУровень(Лог.Уровень());
    Логирование.ПолучитьЛог("oscript.lib.irac").УстановитьУровень(УровниЛога.Отладка);
    
    Попытка
        COMОбъект = Новый COMОбъект(КОМ_КОННЕКТОР);
        Лог.Информация("New com cobject has been created");
    Исключение
        ВызватьИсключение СтрШаблон(НСтр("ru = 'Не удалось создать COM соединение:
                |%1'"), ПодробноеПредставлениеОшибки(ИнформацияОбОшибке()));
    КонецПопытки;
    
КонецПроцедуры

// Устанавливает внешнее соединение с информационной базой по переданным параметрам подключения и возвращает указатель
// на это соединение.
//
// Параметры:
//  ПараметрыПодключения - Структура - Параметры подключения к информационной базе (см. в ОбновитьИнформационнуюБазу()).
//
// Возвращаемое значение:
//  COMОбъект, Неопределено - указатель на COM-объект соединения или Неопределено в случае ошибки;
//
Функция УстановитьВнешнееСоединениеСБазой(АутентификацияОперационнойСистемы = Ложь, ФайловыйВариантРаботы = Ложь)
    
    // Формирование строки соединения.
    ШаблонСтрокиСоединения = "[СтрокаБазы][СтрокаАутентификации];UC=ПакетноеОбновлениеКонфигурацииИБ";
    
    Если ФайловыйВариантРаботы Тогда
        СтрокаБазы = "File = ""&КаталогИнформационнойБазы""";
        СтрокаБазы = СтрЗаменить(СтрокаБазы, "&КаталогИнформационнойБазы", ИМЯ_БАЗЫ);
    Иначе
        СтрокаБазы = "Srvr = ""&ИмяСервера1СПредприятия""; Ref = ""&ИмяИнформационнойБазыНаСервере1СПредприятия""";
        СтрокаБазы = СтрЗаменить(СтрокаБазы, "&ИмяСервера1СПредприятия", СЕРВЕР +
                ?(ЗначениеЗаполнено(ПОРТ_КЛАСТЕРА), ":" + ПОРТ_КЛАСТЕРА, ""));
        СтрокаБазы = СтрЗаменить(СтрокаБазы, "&ИмяИнформационнойБазыНаСервере1СПредприятия", ИМЯ_БАЗЫ);
    КонецЕсли;
    
    Если АутентификацияОперационнойСистемы Тогда
        СтрокаАутентификации = "";
    Иначе
        СтрокаАутентификации = "; Usr = ""&ИмяПользователя""; Pwd = ""&ПарольПользователя""";
        СтрокаАутентификации = СтрЗаменить(СтрокаАутентификации, "&ИмяПользователя", АДМИН_1С_ИМЯ);
        СтрокаАутентификации = СтрЗаменить(СтрокаАутентификации, "&ПарольПользователя", АДМИН_1С_ПАРОЛЬ);
    КонецЕсли;
    
    СтрокаСоединения = СтрЗаменить(ШаблонСтрокиСоединения, "[СтрокаБазы]", СтрокаБазы);
    СтрокаСоединения = СтрЗаменить(СтрокаСоединения, "[СтрокаАутентификации]", СтрокаАутентификации);
    
    Попытка
        Соединение = COMОбъект.Connect(СтрокаСоединения);
        Лог.Информация("Connection to the base has been established");
    Исключение
        Лог.Ошибка(СтрШаблон(НСтр("ru = 'Не удалось подключится к другой программе:
                    |%1, строка соединения %2'"), ПодробноеПредставлениеОшибки(ИнформацияОбОшибке()),
                СтрокаСоединения));
        Возврат Неопределено;
    КонецПопытки;
    
    Возврат Соединение;
    
КонецФункции

Функция ПолучитьИнформационнуюБазуКластера()
    СтрокаПодключения = СтрШаблон("%1:%2", СЕРВЕР, RAC_PORT);
    
    Админка = Новый УправлениеКластером1С(RAC_PATH, СтрокаПодключения, ПЛАТФОРМА_ВЕРСИЯ);
    
    Кластеры = Админка.Кластеры();
    
    ОтборКластеров = Новый Соответствие();
    ОтборКластеров.Вставить("Имя", СтрШаблон("""%1""", ИМЯ_КЛАСТЕРА)); //в отборе имя кластера возвращается в кавычках
    
    СписокКластеров = Кластеры.Список(ОтборКластеров);
    
    Если СписокКластеров.Количество() <> 1 Тогда
        ТекстИсключения = СтрШаблон("Найдено %1 кластеров по отбору ", СписокКластеров.Количество());
        Для Каждого СтрокаОтбора Из ОтборКластеров Цикл
            ТекстИсключения = ТекстИсключения + Символы.ПС + СтрокаОтбора.Ключ + "-" + СтрокаОтбора.Значение;
        КонецЦикла;
        
        ВызватьИсключение ТекстИсключения;
    КонецЕсли;
    
    // Обходим список кластеров
    Для Каждого Кластер Из СписокКластеров Цикл
        Лог.Отладка("Cluster name = " + Кластер.Получить("Имя"));
        
        ИБКластера = Кластер.ИнформационныеБазы();
        
        База = ИБКластера.Получить(ИМЯ_БАЗЫ);
        
        Если База = Неопределено Тогда
            Лог.Отладка("База не найдена");
            Возврат Неопределено;
        КонецЕсли;
        
        Возврат База;
    КонецЦикла;
КонецФункции

Процедура ЗапуститьОтложенноеОбновлениеВИнформационнойБазе(Соединение, ОжидатьЗавершениеВыполнения,
        ПериодичностьПроверкиСостоянияВыполнения = 60, ТаймаутПроверкиСостоянияВыполнения = 3600)
    
    Метаданные = Соединение.Метаданные;
    РегламентныеЗадания = Метаданные.РегламентныеЗадания;
    РегЗадание = РегламентныеЗадания.ОтложенноеОбновлениеИБ;
    
    // Если Не ОжидатьЗавершениеВыполнения Тогда
    //     МодульРеглЗаданий = Соединение.РегламентныеЗаданияСлужебный;
    //     ПараметрыВыполнения = МодульРеглЗаданий.ВыполнитьРегламентноеЗаданиеВручную(РегЗадание);
    //     ПараметрыВыполнения.Вставить("Наименование", РегЗадание.Name);
        
    //     Если ПараметрыВыполнения.ЗапускВыполнен Тогда
    //         Лог.Информация(СтрШаблон(НСтр("ru = '%1.
    //                     |Процедура запущена в фоновом задании %2, начатом %3'"),
    //                 ПараметрыВыполнения.Наименование,
    //                 ПараметрыВыполнения.ПредставлениеФоновогоЗадания,
    //                 Строка(ПараметрыВыполнения.МоментЗапуска)));
    //     ИначеЕсли ПараметрыВыполнения.ПроцедураУжеВыполняется Тогда
            
    //         Лог.Информация(СтрШаблон(НСтр("ru = 'Процедура регламентного задания ""%1""
    //                     | уже выполняется в фоновом задании ""%2"", начатом %3.'"),
    //                 ПараметрыВыполнения.Наименование,
    //                 ПараметрыВыполнения.ПредставлениеФоновогоЗадания,
    //                 Строка(ПараметрыВыполнения.МоментЗапуска)));
    //     Иначе
    //         Освободить(ПараметрыВыполнения);
    //         Освободить(МодульРеглЗаданий);
    //         Освободить(РегЗадание);
    //         Освободить(РегламентныеЗадания);
    //         Освободить(Метаданные);
            
    //         ВызватьИсключение НСтр("ru = 'Неизвестный результат ПараметрыВыполнения после запуска
    //             ||Соединение.РегламентныеЗаданияСлужебный.ВыполнитьРегламентноеЗаданиеВручную'");
    //     КонецЕсли;
        
    //     Возврат;
    // КонецЕсли;
    
    // ВремяЗапускаОтложенногоОбновления = ТекущаяДата();
    
    // МодульОбновления = Соединение.ОбновлениеИнформационнойБазыСлужебный;
    // Сведения = МодульОбновления.СведенияОбОбновленииИнформационнойБазы();

    // // пока выполняется отложенное обновление
    // Пока Сведения.ОтложенноеОбновлениеЗавершеноУспешно = Неопределено Цикл
        МодульРеглЗаданий = Соединение.РегламентныеЗаданияСлужебный;
        МодульРеглЗаданий.ВыполнитьРегламентноеЗаданиеВручную(РегЗадание);

        // если активно, подождем...
        // sleep(ПериодичностьПроверкиСостоянияВыполнения * 1000);
        
        // Если ВремяЗапускаОтложенногоОбновления + ТаймаутПроверкиСостоянияВыполнения < ТекущаяДата() Тогда
        //     Лог.Отладка(СтрШаблон("Завешился таймаут проверки состояния выполнения отложенного обновления %1", ТаймаутПроверкиСостоянияВыполнения));

        //     Освободить(МодульРеглЗаданий);

        //     Прервать;
        // КонецЕсли;

        Освободить(МодульРеглЗаданий);
    //     Освободить(Сведения);

    //     // проверим успешное завершение отложенного обновления
    //     Сведения = МодульОбновления.СведенияОбОбновленииИнформационнойБазы();
    // КонецЦикла;
    
    // Освободить(Сведения);
    // Освободить(МодульОбновления);
    
    Освободить(РегЗадание);
    Освободить(РегламентныеЗадания);
    Освободить(Метаданные);
    
КонецПроцедуры

Процедура ПодождатьЗавершенияСеансов()
    
    ИнтервалОжидания = 120000; // 2 минуты
    МаксимальноеКоличествоИнтервалов = 3;
    
    Сеансы = Новый Массив;
    
    База = ПолучитьИнформационнуюБазуКластера();
    База.УстановитьАдминистратора(АДМИН_1С_ИМЯ, АДМИН_1С_ПАРОЛЬ);
    
    Для Сч = 1 По МаксимальноеКоличествоИнтервалов Цикл
        Сеансы = База.Сеансы().Список();
        
        Если Сеансы.Количество() = 0 Тогда
            Лог.Отладка("Активных сеансов нет");
            Прервать;
        КонецЕсли;

        Лог.Отладка(СтрШаблон("Ждём завершения сеансов #%1 / %2, активных: %3", Сч, МаксимальноеКоличествоИнтервалов,
                Сеансы.Количество()));
        
        sleep(ИнтервалОжидания);
    КонецЦикла;
    
    Сеансы = База.Сеансы().Список();
    
    Если Сеансы.Количество() > 0 Тогда
        КоличествоСеансов = Сеансы.Количество();
        Лог.Отладка(СтрШаблон("Осталось активных: %1", КоличествоСеансов));
        
        Для Сч = 0 По КоличествоСеансов - 1 Цикл
            Лог.Отладка(СтрШаблон("Удаляю сеанс %1", Сч));
            
            Попытка
                Сеанс = Сеансы[Сч];
                Сеанс.Завершить();
            Исключение
                Лог.Отладка("Возникла ошибка при удалении сеанса");
            КонецПопытки;
        КонецЦикла;
    КонецЕсли;
    
КонецПроцедуры

Процедура ВыполнитьОбновлениеИнформационнойБазы()
    
    Соединение = УстановитьВнешнееСоединениеСБазой();
    
    МодульОбновленияИБ = Соединение.ОбновлениеИнформационнойБазыСлужебный;
    МодульОбновленияИБ.ЗаписатьПодтверждениеЛегальностиПолученияОбновлений();
    Освободить(МодульОбновленияИБ);
    
    // ОБНОВЛЕНИЕ РАСШИРЕНИЙ
    МодульОбновленияКонфигурации = Соединение.ОбновлениеКонфигурации;
    Результат = МодульОбновленияКонфигурации.ИсправленияИзменены();
    
    Освободить(Результат);
    Освободить(МодульОбновленияКонфигурации);
    Освободить(Соединение);
    
    // подождем разрыва COM-соединения (максимум 20 минут)
    ПодождатьЗавершенияСеансов();
    
    Соединение = УстановитьВнешнееСоединениеСБазой();
    
    // МОНОПОЛЬНОЕ ОБНОВЛЕНИЕ
    Лог.Отладка("Запускаем Соединение.ОбновлениеИнформационнойБазы.ВыполнитьОбновлениеИнформационнойБазы()");
    МодульОбновленияИБ = Соединение.ОбновлениеИнформационнойБазы;
    РезультатОбновления = МодульОбновленияИБ.ВыполнитьОбновлениеИнформационнойБазы();
    
    Если РезультатОбновления = "Успешно" Тогда
        Лог.Информация(НСтр("ru = 'Принятие обновлений в информационной базе завершено.'"));
        
        Освободить(МодульОбновленияИБ);
        
        // УСТАНОВКА ПРИОРИТЕТА
        МодульОбновленияИБ = Соединение.ОбновлениеИнформационнойБазыСлужебный;
        СведенияОбОбновлении = МодульОбновленияИБ.СведенияОбОбновленииИнформационнойБазы();
        УправлениеОтложеннымОбновлением = СведенияОбОбновлении.УправлениеОтложеннымОбновлением;
        
        Если Не УправлениеОтложеннымОбновлением.Свойство("ФорсироватьОбновление") Тогда
            УправлениеОтложеннымОбновлением.Вставить("ФорсироватьОбновление");
        КонецЕсли;
        УправлениеОтложеннымОбновлением.ФорсироватьОбновление = "ОбработкаДанных";
        МодульОбновленияИБ.ЗаписатьСведенияОбОбновленииИнформационнойБазы(СведенияОбОбновлении);
        
        Освободить(УправлениеОтложеннымОбновлением);
        Освободить(СведенияОбОбновлении);
        Освободить(МодульОбновленияИБ);
        
        // ОТЛОЖЕННОЕ ОБНОВЛЕНИЕ
        ЗапуститьОтложенноеОбновлениеВИнформационнойБазе(Соединение, ОжидатьВыполнениеОтложенныхОбработчиков);
    ИначеЕсли РезультатОбновления = "НеТребуется" Тогда
        Лог.Информация(НСтр("ru = 'Принятие обновлений в информационной базе не требуется.'"));
        
        Освободить(МодульОбновленияИБ);
        
        Попытка
            МодульркДополнительныеОтчетыИОбработки = Неопределено;
            //Попытка
            //    ОбщегоНазначения = Соединение.ОбщегоНазначения;
            //    МодульркДополнительныеОтчетыИОбработки = ОбщегоНазначения.ОбщийМодуль("ркДополнительныеОтчетыИОбработки");
            //Исключение
            //КонецПопытки;
            
            //Если МодульркДополнительныеОтчетыИОбработки <> Неопределено Тогда
            //    Соединение.ркДополнительныеОтчетыИОбработки.ЗагрузитьДополнительныеОтчетыИОбработкиИзМетаданных(Новый Структура("ОбработкаЗавершена"));
            //КонецЕсли;
        Исключение
            ТекстОшибки = СтрШаблон(НСтр("ru = 'Ошибка обновления доп обработок в базе %1:
                        |%2.'"), ИМЯ_БАЗЫ, ПодробноеПредставлениеОшибки(ИнформацияОбОшибке()));
            
            Лог.Ошибка(ТекстОшибки);
        КонецПопытки;
    ИначеЕсли РезультатОбновления = "ОшибкаУстановкиМонопольногоРежима" Тогда
        Освободить(МодульОбновленияИБ);
        
        Освободить(Соединение);
        Освободить(COMОбъект);
        
        ВызватьИсключение "Ошибка обновления: ОшибкаУстановкиМонопольногоРежима";
    Иначе
        Освободить(МодульОбновленияИБ);
        
        Освободить(Соединение);
        Освободить(COMОбъект);
        
        ВызватьИсключение СтрШаблон(НСтр("ru = 'РезультатОбновления: %1'"), РезультатОбновления);
    КонецЕсли;
    
    Освободить(Соединение);
    Освободить(COMОбъект);
    ПодождатьЗавершенияСеансов();
    
КонецПроцедуры

Процедура Освободить(Объект)
    
    Лог.Отладка("Освобождаем " + Объект);
    
    Если Объект <> Неопределено Тогда
        ОсвободитьОбъект(Объект);
    КонецЕсли;
    
КонецПроцедуры

Попытка
    Инициализация();
    
    ВыполнитьОбновлениеИнформационнойБазы();
Исключение
    Лог.Ошибка(ПодробноеПредставлениеОшибки(ИнформацияОбОшибке()));
КонецПопытки;

Лог.Информация("script completed");