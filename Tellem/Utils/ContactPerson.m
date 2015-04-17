//
// Contact Person
//
//  Created by Ed Bayudan on 01/22/2015.
//  Copyright (c) 2015 Tellem. All rights reserved.
//

#import "ContactPerson.h"

@implementation ContactPerson {
}
@synthesize firstName,lastName,phoneNumbers,emailAddresses;

+ (ContactPerson*) personWithFirstName:(NSString*)fName andLastName:(NSString*)lName andPhoneNumbers:(NSMutableArray*)pNums andEmails:(NSMutableArray*)eMails
{
    ContactPerson* contactPerson = [[ContactPerson alloc] init];
    contactPerson.firstName = fName;
    contactPerson.lastName = lName;
    contactPerson.phoneNumbers = pNums;
    contactPerson.emailAddresses = eMails;
    return contactPerson;
}



@end
