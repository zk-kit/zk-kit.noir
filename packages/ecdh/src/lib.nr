pub mod bjj;
pub use ec::tecurve::affine::Point;

pub trait ECDHTrait {
    fn new(private_key: Field) -> Self;
    fn derive_public_key(self) -> Point;
    fn derive_shared_key(self, public_key: Point) -> Field;
}
