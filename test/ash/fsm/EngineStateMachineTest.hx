package ash.fsm;

import ash.core.System;
import ash.core.Engine;
import ash.Mocks.EmptySystem2;

import org.hamcrest.MatchersBase;

class EngineStateMachineTest extends MatchersBaseTestCase
{
    private var fsm:EngineStateMachine;
    private var engine:Engine;

    @Before
    override public function setup():Void
    {
        engine = new Engine();
        fsm = new EngineStateMachine( engine );
    }

    @After
    override public function tearDown():Void
    {
        engine = null;
        fsm = null;
    }

    @Test
    public function testenterStateAddsStatesSystems():Void
    {
        var state:EngineState = new EngineState();
        var system:RemovingSystem = new RemovingSystem();
        state.addInstance(system);
        fsm.addState("test", state);
        fsm.changeState("test");
        assertThat(engine.getSystem(RemovingSystem), sameInstance(system));
    }

    @Test
    public function testenterSecondStateAddsSecondStatesSystems():Void
    {
        var state1:EngineState = new EngineState();
        var system1:RemovingSystem = new RemovingSystem();
        state1.addInstance(system1);
        fsm.addState("test1", state1);
        fsm.changeState("test1");

        var state2:EngineState = new EngineState();
        var system2:EmptySystem2 = new EmptySystem2();
        state2.addInstance(system2);
        fsm.addState("test2", state2);
        fsm.changeState("test2");

        assertThat(engine.getSystem(EmptySystem2), sameInstance(system2));
    }

    @Test
    public function testenterSecondStateRemovesFirstStatesSystems():Void
    {
        var state1:EngineState = new EngineState();
        var system1:RemovingSystem = new RemovingSystem();
        state1.addInstance(system1);
        fsm.addState("test1", state1);
        fsm.changeState("test1");

        var state2:EngineState = new EngineState();
        var system2:EmptySystem2 = new EmptySystem2();
        state2.addInstance(system2);
        fsm.addState("test2", state2);
        fsm.changeState("test2");

        assertThat(engine.getSystem(RemovingSystem), nullValue());
    }

    @Test
    public function testenterSecondStateDoesNotRemoveOverlappingSystems():Void
    {
        var state1:EngineState = new EngineState();
        var system1:RemovingSystem = new RemovingSystem();
        state1.addInstance(system1);
        fsm.addState("test1", state1);
        fsm.changeState("test1");

        var state2:EngineState = new EngineState();
        var system2:EmptySystem2 = new EmptySystem2();
        state2.addInstance(system1);
        state2.addInstance(system2);
        fsm.addState("test2", state2);
        fsm.changeState("test2");

        assertThat(system1.wasRemoved, is(false));
        assertThat(engine.getSystem(RemovingSystem), sameInstance(system1));
    }

    @Test
    public function testenterSecondStateRemovesDifferentSystemsOfSameType():Void
    {
        var state1:EngineState = new EngineState();
        var system1:RemovingSystem = new RemovingSystem();
        state1.addInstance(system1);
        fsm.addState("test1", state1);
        fsm.changeState("test1");

        var state2:EngineState = new EngineState();
        var system3:RemovingSystem = new RemovingSystem();
        var system2:EmptySystem2 = new EmptySystem2();
        state2.addInstance(system3);
        state2.addInstance(system2);
        fsm.addState("test2", state2);
        fsm.changeState("test2");

        assertThat(engine.getSystem(RemovingSystem), sameInstance(system3));
    }
}


class RemovingSystem extends System
{
    public var wasRemoved:Bool = false;

    override public function removeFromEngine(engine:Engine):Void
    {
        wasRemoved = true;
    }
}
