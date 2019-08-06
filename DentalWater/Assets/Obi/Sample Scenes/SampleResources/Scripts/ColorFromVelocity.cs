using UnityEngine;
using System;
using System.Collections;
using System.Collections.Generic;

namespace Obi
{
	/**
	 * Sample script that colors fluid particles based on their vorticity (2D only)
	 */
	[RequireComponent(typeof(ObiEmitter))]
	public class ColorFromVelocity : MonoBehaviour
	{
		ObiEmitter emitter;
		public float sensibility = 0.2f;

		void Awake(){
			emitter = GetComponent<ObiEmitter>();
			emitter.OnAddedToSolver += Emitter_OnAddedToSolver;
			emitter.OnRemovedFromSolver += Emitter_OnRemovedFromSolver;
		}

		void Emitter_OnAddedToSolver (object sender, ObiActor.ObiActorSolverArgs e)
		{
			e.Solver.OnFrameEnd += E_Solver_OnFrameEnd;
		}

		void Emitter_OnRemovedFromSolver (object sender, ObiActor.ObiActorSolverArgs e)
		{
			e.Solver.OnFrameEnd -= E_Solver_OnFrameEnd;
		}

		public void OnEnable(){}

		void E_Solver_OnFrameEnd (object sender, EventArgs e)
		{
			if (!isActiveAndEnabled)
				return;

			for (int i = 0; i < emitter.particleIndices.Length; ++i){

				int k = emitter.particleIndices[i];

				Vector4 vel = emitter.Solver.velocities[k];

				emitter.colors[i] = new Color(Mathf.Clamp(vel.x / sensibility,-1,1) * 0.5f + 0.5f,
											  Mathf.Clamp(vel.y / sensibility,-1,1) * 0.5f + 0.5f,
											  Mathf.Clamp(vel.z / sensibility,-1,1) * 0.5f + 0.5f,1);

			}
		}
	
	}
}

