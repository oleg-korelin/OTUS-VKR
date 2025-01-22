﻿
Процедура ОбработкаПроведения(Отказ, Режим)
	//{{__КОНСТРУКТОР_ДВИЖЕНИЙ_РЕГИСТРОВ
	// Данный фрагмент построен конструктором.
	// При повторном использовании конструктора, внесенные вручную изменения будут утеряны!!!

	// регистр ОстаткиПодарочныхСертификатов Приход
	Движения.ОстаткиПодарочныхСертификатов.Записывать = Истина;
	Для Каждого ТекСтрокаТЧПодрочныеСертификаты Из ТЧПодрочныеСертификаты Цикл
		Движение = Движения.ОстаткиПодарочныхСертификатов.Добавить();
		Движение.ВидДвижения = ВидДвиженияНакопления.Приход;
		Движение.Период = Дата;
		Движение.Сертификат = ТекСтрокаТЧПодрочныеСертификаты.НомерСертификата;
		Движение.СуммаОстаток = ТекСтрокаТЧПодрочныеСертификаты.СуммаСертификата;
	КонецЦикла;

	//}}__КОНСТРУКТОР_ДВИЖЕНИЙ_РЕГИСТРОВ
КонецПроцедуры
