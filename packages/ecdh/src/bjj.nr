use crate::ECDHTrait;
use edwards::bjj::BabyJubJub as Point;
use edwards::CurveTrait;
use edwards::ScalarField;

// BASE8 generator point (8 * G) for Baby Jubjub curve
global BASE8_X: Field = 0xbb77a6ad63e739b4eacb2e09d6277c12ab8d8010534e0b62893f3f6bb957051;
global BASE8_Y: Field = 0x25797203f7a0b24925572e1cd16bf9edfce0051fb9e133774b3c257a872d7d8b;

// Baby Jubjub subgroup order (prime r where curve order = 8 * r)
// r = 2736030358979909402780800718157159386076813972158567259200215660948447373041
global SUBGROUP_ORDER: [u1; 251] = [
    1, 0, 0, 0, 1, 1, 1, 1, 0, 1, 1, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 1, 1, 1, 0, 0,
    0, 0, 1, 1, 1, 0, 1, 1, 1, 1, 1, 0, 1, 0, 0, 1, 0, 1, 0, 0, 1, 1, 1, 0, 1, 1, 1, 0, 0, 1, 1, 0,
    0, 1, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1, 0, 1, 1, 1, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 1, 1, 1, 0, 0,
    0, 0, 0, 1, 1, 1, 0, 1, 1, 0, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 1, 1, 0, 0, 1, 1, 0, 1, 0, 1, 0, 1,
    1, 1, 0, 1, 0, 0, 0, 0, 1, 1, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 1, 0, 1, 1,
    0, 1, 1, 0, 1, 1, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 1, 1, 1, 0, 1, 1, 0, 0,
    1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 1, 0, 0, 0, 1, 1, 0, 0, 1, 0, 0, 0, 0, 1, 1, 1, 0, 1, 0,
    0, 1, 1, 1, 0, 0, 1, 1, 1, 0, 0, 1, 0, 0, 0, 1, 0, 0, 1, 1, 0, 0, 0, 0, 0, 1, 1,
];

/// Checks if a point is in the prime-order subgroup of Baby Jubjub.
/// Returns true if r * P = identity (where r is the subgroup order).
pub fn check_subgroup(point: Point) -> bool {
    let mut p = point;
    for i in 0..250 {
        p = p + p; // double
        if SUBGROUP_ORDER[249 - i] == 1 {
            p = p + point; // add
        }
    }
    p.is_zero()
}

pub struct BJJ {
    pub private_key: Field,
}

impl ECDHTrait for BJJ {
    fn new(private_key: Field) -> Self {
        Self { private_key }
    }

    fn derive_public_key(self) -> Point {
        let base8 = Point::new(BASE8_X, BASE8_Y);
        let scalar: ScalarField<63> = ScalarField::from(self.private_key);
        base8.mul(scalar)
    }

    fn derive_shared_key(self, public_key: Point) -> Field {
        // Validate public key is on curve and in prime-order subgroup
        // This prevents small subgroup attacks on Baby Jubjub (cofactor 8)
        assert(public_key.is_on_curve(), "Public key not on curve");
        assert(check_subgroup(public_key), "Public key not in valid subgroup");

        let scalar: ScalarField<63> = ScalarField::from(self.private_key);
        let shared_key = public_key.mul(scalar);
        shared_key.x
    }
}
