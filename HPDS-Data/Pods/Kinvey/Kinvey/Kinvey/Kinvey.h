//
//  Kinvey.h
//  Kinvey
//
//  Created by Victor Barros on 2015-12-08.
//  Copyright © 2015 Kinvey. All rights reserved.
//

@import Foundation;

//! Project version number for Kinvey.
FOUNDATION_EXPORT double KinveyVersionNumber;

//! Project version string for Kinvey.
FOUNDATION_EXPORT const unsigned char KinveyVersionString[];

NS_INLINE NSException * _Nullable tryBlock(void(^_Nonnull tryBlock)(void)) {
    @try {
        tryBlock();
    }
    @catch (NSException *exception) {
        return exception;
    }
    return nil;
}
