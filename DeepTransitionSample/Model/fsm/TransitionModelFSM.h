/*
 * ex: set ro:
 * DO NOT EDIT.
 * generated by smc (http://smc.sourceforge.net/)
 * from file : TransitionModelFSM.sm
 */


#import "statemap.h"

// Forward declarations.
@class TransitionModelStateMap;
@class TransitionModelStateMap_IDLE;
@class TransitionModelStateMap_CONFIRMING;
@class TransitionModelStateMap_REMOVING;
@class TransitionModelStateMap_ADDING;
@class TransitionModelStateMap_FINISH_ADD;
@class TransitionModelStateMap_Default;
@class TransitionViewControllerModelState;
@class TransitionModelFSM;
@class TransitionViewControllerModel;

@interface TransitionViewControllerModelState : SMCState
{
}
- (void)Entry:(TransitionModelFSM*)context;
- (void)Exit:(TransitionModelFSM*)context;

- (void)add:(TransitionModelFSM*)context;
- (void)cancel:(TransitionModelFSM*)context;
- (void)finish_add:(TransitionModelFSM*)context :(id)vc;
- (void)finish_transition:(TransitionModelFSM*)context;
- (void)ok:(TransitionModelFSM*)context;
- (void)request:(TransitionModelFSM*)context :(NSString*)destination;
- (void)stop:(TransitionModelFSM*)context;

- (void)Default:(TransitionModelFSM*)context;
@end

@interface TransitionModelStateMap : NSObject
{
}
+ (TransitionModelStateMap_IDLE*)IDLE;
+ (TransitionModelStateMap_CONFIRMING*)CONFIRMING;
+ (TransitionModelStateMap_REMOVING*)REMOVING;
+ (TransitionModelStateMap_ADDING*)ADDING;
+ (TransitionModelStateMap_FINISH_ADD*)FINISH_ADD;
@end

@interface TransitionModelStateMap_Default : TransitionViewControllerModelState
{
}
- (void)stop:(TransitionModelFSM*)context;
- (void)Default:(TransitionModelFSM*)context;
@end

@interface TransitionModelStateMap_IDLE : TransitionModelStateMap_Default
{
}
 -(void)Entry:(TransitionModelFSM*)context;
- (void)request:(TransitionModelFSM*)context :(NSString*)destination;
@end

@interface TransitionModelStateMap_CONFIRMING : TransitionModelStateMap_Default
{
}
- (void)cancel:(TransitionModelFSM*)context;
- (void)ok:(TransitionModelFSM*)context;
@end

@interface TransitionModelStateMap_REMOVING : TransitionModelStateMap_Default
{
}
 -(void)Entry:(TransitionModelFSM*)context;
- (void)add:(TransitionModelFSM*)context;
@end

@interface TransitionModelStateMap_ADDING : TransitionModelStateMap_Default
{
}
 -(void)Entry:(TransitionModelFSM*)context;
- (void)finish_add:(TransitionModelFSM*)context :(id)vc;
@end

@interface TransitionModelStateMap_FINISH_ADD : TransitionModelStateMap_Default
{
}
- (void)add:(TransitionModelFSM*)context;
- (void)finish_transition:(TransitionModelFSM*)context;
@end

@interface TransitionModelFSM : SMCFSMContext
{
    __weak TransitionViewControllerModel *_owner;
}
- (id)initWithOwner:(TransitionViewControllerModel*)owner;
- (id)initWithOwner:(TransitionViewControllerModel*)owner state:(SMCState*)aState;
- (TransitionViewControllerModel*)owner;
- (TransitionViewControllerModelState*)state;

- (void)enterStartState;

- (void)add;
- (void)cancel;
- (void)finish_add:(id)vc;
- (void)finish_transition;
- (void)ok;
- (void)request:(NSString*)destination;
- (void)stop;
@end


/*
 * Local variables:
 *  buffer-read-only: t
 * End:
 */