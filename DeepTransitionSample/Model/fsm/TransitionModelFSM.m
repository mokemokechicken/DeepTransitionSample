/* Generator: http://goodparts.d.yumemi.jp/generator#StateMachineGenerator--2400cc4a764d7de0c18d9c47bd417f7455f598ed
 * ex: set ro:
 * DO NOT EDIT.
 * generated by smc (http://smc.sourceforge.net/)
 * from file : TransitionModelFSM.sm
 */

#import "DeepTransitionSample-Swift.h"
#import "TransitionModelFSM.h"
// Class declarations.
@implementation TransitionModelStateMap
    static TransitionModelStateMap_IDLE *gTransitionModelStateMap_IDLE = nil;
    static TransitionModelStateMap_CONFIRMING *gTransitionModelStateMap_CONFIRMING = nil;
    static TransitionModelStateMap_REMOVING *gTransitionModelStateMap_REMOVING = nil;
    static TransitionModelStateMap_ADDING *gTransitionModelStateMap_ADDING = nil;
    static TransitionModelStateMap_FINISH_ADD *gTransitionModelStateMap_FINISH_ADD = nil;

+ (TransitionModelStateMap_IDLE*)IDLE;
{
    if (!gTransitionModelStateMap_IDLE)
    {
        gTransitionModelStateMap_IDLE = [[TransitionModelStateMap_IDLE alloc] initWithName:@"TransitionModelStateMap::IDLE" stateId:0];
    }
    return gTransitionModelStateMap_IDLE;
}

+ (TransitionModelStateMap_CONFIRMING*)CONFIRMING;
{
    if (!gTransitionModelStateMap_CONFIRMING)
    {
        gTransitionModelStateMap_CONFIRMING = [[TransitionModelStateMap_CONFIRMING alloc] initWithName:@"TransitionModelStateMap::CONFIRMING" stateId:0];
    }
    return gTransitionModelStateMap_CONFIRMING;
}

+ (TransitionModelStateMap_REMOVING*)REMOVING;
{
    if (!gTransitionModelStateMap_REMOVING)
    {
        gTransitionModelStateMap_REMOVING = [[TransitionModelStateMap_REMOVING alloc] initWithName:@"TransitionModelStateMap::REMOVING" stateId:0];
    }
    return gTransitionModelStateMap_REMOVING;
}

+ (TransitionModelStateMap_ADDING*)ADDING;
{
    if (!gTransitionModelStateMap_ADDING)
    {
        gTransitionModelStateMap_ADDING = [[TransitionModelStateMap_ADDING alloc] initWithName:@"TransitionModelStateMap::ADDING" stateId:0];
    }
    return gTransitionModelStateMap_ADDING;
}

+ (TransitionModelStateMap_FINISH_ADD*)FINISH_ADD;
{
    if (!gTransitionModelStateMap_FINISH_ADD)
    {
        gTransitionModelStateMap_FINISH_ADD = [[TransitionModelStateMap_FINISH_ADD alloc] initWithName:@"TransitionModelStateMap::FINISH_ADD" stateId:0];
    }
    return gTransitionModelStateMap_FINISH_ADD;
}

+ (void) cleanupStates
{
    [gTransitionModelStateMap_IDLE S_RELEASE]; gTransitionModelStateMap_IDLE = nil;
    [gTransitionModelStateMap_CONFIRMING S_RELEASE]; gTransitionModelStateMap_CONFIRMING = nil;
    [gTransitionModelStateMap_REMOVING S_RELEASE]; gTransitionModelStateMap_REMOVING = nil;
    [gTransitionModelStateMap_ADDING S_RELEASE]; gTransitionModelStateMap_ADDING = nil;
    [gTransitionModelStateMap_FINISH_ADD S_RELEASE]; gTransitionModelStateMap_FINISH_ADD = nil;
}
@end

@implementation TransitionViewControllerModelState
- (void)Entry:(TransitionModelFSM*)context
{
}
- (void)Exit:(TransitionModelFSM*)context
{
}
- (void)add:(TransitionModelFSM*)context;
{
    [self Default:context];
}
- (void)cancel:(TransitionModelFSM*)context;
{
    [self Default:context];
}
- (void)finish_add:(TransitionModelFSM*)context :(id)vc;
{
    [self Default:context];
}
- (void)finish_remove:(TransitionModelFSM*)context :(id)vc;
{
    [self Default:context];
}
- (void)finish_transition:(TransitionModelFSM*)context;
{
    [self Default:context];
}
- (void)ok:(TransitionModelFSM*)context;
{
    [self Default:context];
}
- (void)request:(TransitionModelFSM*)context :(NSString*)destination;
{
    [self Default:context];
}
- (void)skip_removing:(TransitionModelFSM*)context;
{
    [self Default:context];
}
- (void)stop:(TransitionModelFSM*)context;
{
    [self Default:context];
}

- (void)Default:(TransitionModelFSM*)context;
{
    NSAssert( NO, @"Default transition" );
}
@end


@implementation TransitionModelStateMap_Default

- (void)stop:(TransitionModelFSM*)context;
{
    [[context state] Exit:context];
    [context setState:[TransitionModelStateMap IDLE]];
    [[context state] Entry:context];
}

- (void)Default:(TransitionModelFSM*)context;
{
}
@end
@implementation TransitionModelStateMap_IDLE
- (void)Entry:(TransitionModelFSM*)context;

{
    TransitionViewControllerModel *ctxt = [context owner];

    [ctxt onEntryIdle];
}

- (void)request:(TransitionModelFSM*)context :(NSString*)destination;
{
    TransitionViewControllerModel *ctxt = [context owner];
    [[context state] Exit:context];
    [context clearState];
    [ctxt onRequestConfirming:destination];
    [context setState:[TransitionModelStateMap CONFIRMING]];
    [[context state] Entry:context];
}
@end

@implementation TransitionModelStateMap_CONFIRMING

- (void)cancel:(TransitionModelFSM*)context;
{
    [[context state] Exit:context];
    [context setState:[TransitionModelStateMap IDLE]];
    [[context state] Entry:context];
}

- (void)ok:(TransitionModelFSM*)context;
{
    [[context state] Exit:context];
    [context setState:[TransitionModelStateMap REMOVING]];
    [[context state] Entry:context];
}
@end

@implementation TransitionModelStateMap_REMOVING
- (void)Entry:(TransitionModelFSM*)context;

{
    TransitionViewControllerModel *ctxt = [context owner];

    [ctxt onEntryRemoving];
}

- (void)finish_remove:(TransitionModelFSM*)context :(id)vc;
{
    TransitionViewControllerModel *ctxt = [context owner];
    if ( [ctxt isExpectedReporter:vc] )
    {
        [[context state] Exit:context];
        // No actions.
        [context setState:[TransitionModelStateMap ADDING]];
        [[context state] Entry:context];
    }
    else
    {
         [super finish_remove:context :vc];
    }
}

- (void)skip_removing:(TransitionModelFSM*)context;
{
    [[context state] Exit:context];
    [context setState:[TransitionModelStateMap ADDING]];
    [[context state] Entry:context];
}
@end

@implementation TransitionModelStateMap_ADDING
- (void)Entry:(TransitionModelFSM*)context;

{
    TransitionViewControllerModel *ctxt = [context owner];

    [ctxt onEntryAdding];
}

- (void)finish_add:(TransitionModelFSM*)context :(id)vc;
{
    TransitionViewControllerModel *ctxt = [context owner];
    if ( [ctxt isExpectedChild:vc] )
    {
        [[context state] Exit:context];
        [context clearState];
        [ctxt onFinishAdd:vc];
        [context setState:[TransitionModelStateMap FINISH_ADD]];
        [[context state] Entry:context];
    }
    else
    {
         [super finish_add:context :vc];
    }
}
@end

@implementation TransitionModelStateMap_FINISH_ADD
- (void)Entry:(TransitionModelFSM*)context;

{
    TransitionViewControllerModel *ctxt = [context owner];

    [ctxt onEntryFinishAdd];
}

- (void)add:(TransitionModelFSM*)context;
{
    [[context state] Exit:context];
    [context setState:[TransitionModelStateMap ADDING]];
    [[context state] Entry:context];
}

- (void)finish_transition:(TransitionModelFSM*)context;
{
    [[context state] Exit:context];
    [context setState:[TransitionModelStateMap IDLE]];
    [[context state] Entry:context];
}
@end

@implementation TransitionModelFSM
- (id)initWithOwner:(TransitionViewControllerModel*)owner;
{
    self = [super initWithState:[TransitionModelStateMap IDLE]];
    if (!self)
{
        return nil;
    }
    _owner = owner;
    return self;
}
- (id)initWithOwner:(TransitionViewControllerModel*)owner state:(SMCState*)aState;
{
    self = [super initWithState: aState];
    if (!self)
{
        return nil;
    }
    _owner = owner;
    return self;
}
- (void)dealloc
{
    [TransitionModelStateMap cleanupStates];
    [super S_DEALLOC];
}
- (TransitionViewControllerModelState*)state;
{
    return (TransitionViewControllerModelState*)_state;
}
- (TransitionViewControllerModel*)owner;
{
    return _owner;
}
- (void)enterStartState;
{
    [[self state] Entry:self];
}

- (void)add;
{
    [[self state] add:self];
}

- (void)cancel;
{
    [[self state] cancel:self];
}

- (void)finish_add:(id)vc;
{
    [[self state] finish_add:self :vc];
}

- (void)finish_remove:(id)vc;
{
    [[self state] finish_remove:self :vc];
}

- (void)finish_transition;
{
    [[self state] finish_transition:self];
}

- (void)ok;
{
    [[self state] ok:self];
}

- (void)request:(NSString*)destination;
{
    [[self state] request:self :destination];
}

- (void)skip_removing;
{
    [[self state] skip_removing:self];
}

- (void)stop;
{
    [[self state] stop:self];
}
@end

/*
 * Local variables:
 *  buffer-read-only: t
 * End:
 */
