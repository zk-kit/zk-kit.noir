pub mod bjj;
pub use edwards::bjj::BabyJubJub as Point;
pub use edwards::CurveTrait;

pub trait ECDHTrait {
    fn new(private_key: Field) -> Self;
    fn derive_public_key(self) -> Point;
    fn derive_shared_key(self, public_key: Point) -> Field;
}
