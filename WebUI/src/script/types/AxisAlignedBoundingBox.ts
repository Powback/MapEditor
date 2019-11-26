import { Vec3 } from '@/script/types/primitives/Vec3';
import { LinearTransform } from '@/script/types/primitives/LinearTransform';

export class AxisAlignedBoundingBox {
	public static FromTable(table: any) {
		const min = new Vec3().setFromTable(table.min);
		const max = new Vec3().setFromTable(table.max);
		const transform = new LinearTransform().setFromTable(table.transform);
		return new AxisAlignedBoundingBox(min, max, transform);
	}

	constructor(public min: Vec3, public max: Vec3, public transform: LinearTransform) {
	}
}
