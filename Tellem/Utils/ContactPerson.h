//
// Contact Person
//
//  Created by Ed Bayudan on 01/22/2015.
//  Copyright (c) 2015 Tellem. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ContactPerson : NSObject {}

@property(nonatomic,strong) NSString *firstName;
@property(nonatomic,strong) NSString *lastName;
@property(nonatomic,strong) NSMutableArray *emailAddresses;
@property(nonatomic,strong) NSMutableArray *phoneNumbers;
@property(nonatomic,strong) UIImage *ersonImage;
@property(nonatomic,strong) NSString  *personImageURl;

+ (ContactPerson*) personWithFirstName:(NSString*)fName andLastName:(NSString*)lName andPhoneNumbers:(NSMutableArray*)pNums andEmails:(NSMutableArray*)eMails;

@end
