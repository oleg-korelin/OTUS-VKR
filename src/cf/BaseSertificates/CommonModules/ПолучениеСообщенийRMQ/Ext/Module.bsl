﻿
Процедура ВыполнитьПолучениеСообщений() Экспорт

	КлиентКомпоненты = ПолучитьКомпонентуСервер();
	ПрочитатьСообщениеКлиентСервер(КлиентКомпоненты);

КонецПроцедуры // ВыполнитьПолучениеСообщений()

Процедура ПрочитатьСообщениеКлиентСервер(КлиентКомпоненты)
	
		
		
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ИменаОчередейRMQ.Наименование КАК Наименование
		|ИЗ
		|	Справочник.ИменаОчередейRMQ КАК ИменаОчередейRMQ
		|ГДЕ          
		|	НЕ ИменаОчередейRMQ.ПометкаУдаления";
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Если Не РезультатЗапроса.Пустой() Тогда
		
		Выборка = РезультатЗапроса.Выбрать();
		
		Попытка
			КлиентКомпоненты.Connect(
			"localhost", // Адрес,
			5672, // Порт,
			"guest", // Логин,
			"guest", // Пароль,
			"/"); // ВиртуальныйХост);
			
			
			
			Пока Выборка.Следующий() Цикл
				ИмяОчереди = Выборка.Наименование;
				
				Попытка
					//КлиентКомпоненты.DeclareQueue(ИмяОчереди, Ложь, Ложь, Ложь, Ложь);
					
					Потребитель = КлиентКомпоненты.BasicConsume(ИмяОчереди, "", Истина, Ложь, 0);
					
					ОтветноеСообщение = "";
					Пока КлиентКомпоненты.BasicConsumeMessage("", ОтветноеСообщение, 5) Цикл
						КлиентКомпоненты.BasicAck();
						ТекстСообщения = НСтр("ru='Сообщение успешно прочитано!'");
						
						Если ИмяОчереди = "reference1" Тогда
							
							ЧтениеJSON = Новый ЧтениеJSON;
							ЧтениеJSON.УстановитьСтроку(ОтветноеСообщение);
							ЗначениеОбъект = СериализаторXDTO.ПрочитатьJSON(ЧтениеJSON);
							ЧтениеJSON.Закрыть();
							
							ЗначениеОбъект.Записать(РежимЗаписиДокумента.Проведение); 
							
						ИначеЕсли ИмяОчереди = "reference4" Тогда	
							
							ЧтениеJSON = Новый ЧтениеJSON;
							ЧтениеJSON.УстановитьСтроку(ОтветноеСообщение);
							Значение = ПрочитатьJSON(ЧтениеJSON, Истина);
							ЧтениеJSON.Закрыть();
							
							РегистраторСписанияСумм = Документы.СписаниеСуммПодарочныхСертификатов.СоздатьДокумент();
							РегистраторСписанияСумм.Дата = ТекущаяДатаСеанса();
							РегистраторСписанияСумм.Сертификат = Значение.Получить("sertifikat");
							РегистраторСписанияСумм.СуммаСписания = Значение.Получить("summ_spisaniya");
							РегистраторСписанияСумм.Записать(РежимЗаписиДокумента.Проведение);
							
						ИначеЕсли ИмяОчереди = "reference2" Тогда
							
							Сертификат = ОтветноеСообщение;
							
							Запрос = Новый Запрос;
							Запрос.Текст = 
							"ВЫБРАТЬ
							|	ОстаткиПодарочныхСертификатовОстатки.СуммаОстатокОстаток КАК СуммаОстатокОстаток
							|ИЗ
							|	РегистрНакопления.ОстаткиПодарочныхСертификатов.Остатки(, Сертификат = &Сертификат) КАК ОстаткиПодарочныхСертификатовОстатки";
							
							Запрос.УстановитьПараметр("Сертификат", Сертификат);
							
							Если Запрос.Выполнить().Пустой() Тогда
								СуммаОстаток = 0;
							Иначе
								Выборка = Запрос.Выполнить().Выбрать();
								
								Пока Выборка.Следующий() Цикл
									СуммаОстаток = Выборка.СуммаОстатокОстаток;
								КонецЦикла;
							КонецЕсли;
							
							ОтправкаСообщенийRMQ.ПроверитьПодключениеСервер();
							ТекстСообщения = Строка(СуммаОстаток);
							ТочкаОбмена = "references";
							ИмяОчереди = "reference3";
							КлючМаршрутизации = "reference3";
							ОтправкаСообщенийRMQ.СозданиеТочкиИОчередиСервер(ТочкаОбмена, ИмяОчереди);
							КлиентКомпоненты = ОтправкаСообщенийRMQ.ПолучитьКомпонентуСервер();
							РезультатОтправки = ОтправкаСообщенийRMQ.ОтправитьСообщениеКлиентСервер(КлиентКомпоненты, ТекстСообщения, ТочкаОбмена, ИмяОчереди, КлючМаршрутизации);
						КонецЕсли;	
					КонецЦикла;	
					
					КлиентКомпоненты.BasicCancel("");
				Исключение
					ВызватьИсключение КлиентКомпоненты.GetLastError();
				КонецПопытки;
			КонецЦикла;
			
		Исключение
			СистемнаяОшибка = ОписаниеОшибки();
			ТекстСообщения = "Ошибка чтения сообщения!%СистемнаяОшибка%";
			ТекстСообщения = СтрЗаменить(ТекстСообщения, "%СистемнаяОшибка%", СистемнаяОшибка);
			ЗаписьЖурналаРегистрации("RabbitMQЗагрузка", УровеньЖурналаРегистрации.Ошибка, , , ТекстСообщения);
		КонецПопытки;
	КонецЕсли;
	
КонецПроцедуры

Функция ПолучитьКомпонентуСервер()
	
	КлиентКомпоненты = Неопределено;
	Если Не ИнициализироватьКомпонентуКлиентСервер(КлиентКомпоненты) Тогда
		
		ПодключитьКомпонентуСервер();
		ИнициализироватьКомпонентуКлиентСервер(КлиентКомпоненты);
		
	КонецЕсли;
	
	Возврат КлиентКомпоненты;
КонецФункции

Функция ИнициализироватьКомпонентуКлиентСервер(Компонента)
	
	Попытка
		Компонента  = Новый("AddIn.BITERP.PinkRabbitMQ");
		Возврат Истина;
	Исключение
		Возврат Ложь;
	КонецПопытки;
	
КонецФункции

Процедура ПодключитьКомпонентуСервер(КомпонентаПодключена = Неопределено)
	
	АдресВоВременномХранилище = ПолучитьАдресМакетаКомпановкиНаСервере();
	КомпонентаПодключена = ПодключитьВнешнююКомпоненту(
			АдресВоВременномХранилище,
			"BITERP",
			ТипВнешнейКомпоненты.Native);
	Сообщить(НСтр("ru = 'Компонента подключена!'"));
КонецПроцедуры

Функция ПолучитьАдресМакетаКомпановкиНаСервере()
	
	МакетВнешнейКомпоненты    = ПолучитьОбщийМакет("ВнешняяКомпонента");
	АдресВоВременномХранилище = ПоместитьВоВременноеХранилище(МакетВнешнейКомпоненты);
	
	Возврат АдресВоВременномХранилище;
	
КонецФункции