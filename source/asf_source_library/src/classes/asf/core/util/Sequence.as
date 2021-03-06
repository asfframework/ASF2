/*
Class: asf.core.util.Sequence
Author: Neto Leal
Created: Apr 27, 2011

The MIT License
Copyright (c) 2011 Neto Leal

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/
package asf.core.util
{
	import asf.core.elements.Section;
	import asf.events.SequenceEvent;
	import asf.interfaces.IDisposable;
	import asf.interfaces.ISequence;
	import asf.utils.Delay;
	
	import flash.events.EventDispatcher;
	
	[Event( name="transitionStart", type="asf.events.SequenceEvent")]
	[Event( name="transitionComplete", type="asf.events.SequenceEvent")]
	
	public class Sequence extends EventDispatcher implements ISequence
	{
		private var _completed:Boolean;
		private var _started:Boolean;
		
		private var _queueTransition:Sequence;
		private var _queueAction:Function;
		private var _queueActionArgs:Array;
		
		
		public function Sequence( )
		{
			super( null );
		}
		
		public function notifyStart( ):ISequence
		{
			var e:SequenceEvent = new SequenceEvent( SequenceEvent.TRANSITION_START );
				
			_started = true;
			_completed = false;
			
			this.dispatchEvent( e );
			
			return this;
		}
		
		public function notifyComplete( ):ISequence
		{
			var e:SequenceEvent = new SequenceEvent( SequenceEvent.TRANSITION_COMPLETE );
			
			_started = false;
			_completed = true;
			
			executeQueue( );
			
			this.dispatchEvent( e );
			
			return this;
		}
		
		private function executeQueue( ):void
		{
			if( this._queueTransition && this._queueAction != null )
			{
				var _queueTransition:ISequence = this._queueTransition;
				var actionResult:* = _queueAction.apply( null, _queueActionArgs );
				
				_queueTransition.notifyStart( );
				
				if( actionResult is ISequence )
				{
					( actionResult as EventDispatcher ).addEventListener( SequenceEvent.TRANSITION_COMPLETE, function( e:SequenceEvent ):void
					{
						_queueTransition.notifyComplete( );
					} );
				}
				else
				{
					_queueTransition.notifyComplete( );
				}
				
				clearQueue( );
			}
		}
		
		public function clearQueue( ):void
		{
			_queueAction = null;
			_queueActionArgs = null;
		}
		
		public function queue( queueAction:Function, ... args ):ISequence
		{
			_queueTransition = new Sequence( );
			
			_queueAction = queueAction;
			_queueActionArgs = args;
			
			if( this.completed )
			{
				executeQueue( );
			}
			
			return _queueTransition;
		}
		
		public function delay( milliseconds:uint = 0 ):ISequence
		{
			return Delay.start( milliseconds );
		}
		
		public function get completed( ):Boolean
		{
			return _completed;
		}
		
		public function get started( ):Boolean
		{
			return _started;
		}
		
		public function dispose( ):void
		{
			if( _queueTransition ) _queueTransition.dispose( );
			
			_queueTransition = null;
			_queueAction = null;
			_queueActionArgs = null;
		}
	}
}