//
//  DebugPrint.h
//  MixMac
//
//  Created by Водолазкий В.В. on 14.02.15.
//  Copyright (c) 2015 Geomatix Laboratoriy S.R.O. All rights reserved.
//

#ifndef MixMac_DebugPrint_h
#define MixMac_DebugPrint_h

//
// Сервисные макросы для вывода отладочной информации с указанием класса, метода и номера строки
// См. http://stackoverflow.com/questions/969130/how-to-print-out-the-method-name-and-line-number-and-conditionally-disable-NSLog
//

#ifdef DEBUG
#   define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#   define DLog(...)
#endif

// ALog always displays output regardless of the DEBUG setting
#define ALog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)

// Вывод отладочной информации в UIAlert.
//#ifdef DEBUG
#   define ULog(fmt, ...)  { UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%s\n [Line %d] ", __PRETTY_FUNCTION__, __LINE__] message:[NSString stringWithFormat:fmt, ##__VA_ARGS__]  delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil]; [alert show]; }
//#else
//#   define ULog(...)
//#endif


/**
 RStr - Resource String
 Provides localized string from default localization storage
 */
#define RStr(name) NSLocalizedString(name, name)


#endif
