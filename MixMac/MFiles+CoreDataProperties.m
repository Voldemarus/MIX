//
//  MFiles+CoreDataProperties.m
//  MixMac
//
//  Created by Dmitry Likhtarov on 10/01/2019.
//  Copyright © 2019 Geomatix Laboratoriy S.R.O. All rights reserved.
//
//

#import "MFiles+CoreDataProperties.h"

@implementation MFiles (CoreDataProperties)

+ (NSFetchRequest<MFiles *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"MFiles"];
}

@dynamic fileName;
@dynamic lines;

@end
