use ecdh::{bjj::BJJ, CurveTrait, ECDHTrait, Point};

global alice_sk: Field = 0x60c0102756aac2cf5d7277792a469bff83dfe3d3e7e50ad5a55383f3a89283e;
global bob_sk: Field = 0x86cdaad8886954a2eb20142fb98468d476a2d6c7b2c571af42cdc041b1a923c;

#[test]
fn test_pk() {
    let ecdh = BJJ::new(alice_sk);
    let expected_pk = Point::new(
        0x17d6ff45a37eee4ca071bb451c09b47184ed67492c6bac9279fb0a7d2d4ad1dc,
        0x02d3a6338eee1ae8a38b278ce6c13179889c780f5e0d7294b904b0fa52c7dc3e,
    );
    let pk = ecdh.derive_public_key();
    assert(pk == expected_pk);
}

#[test]
fn test_shared_k() {
    let alice_ecdh = BJJ::new(alice_sk);
    let bob_ecdh = BJJ::new(bob_sk);

    let alice_pk: Point = alice_ecdh.derive_public_key();
    let bob_pk: Point = bob_ecdh.derive_public_key();

    let shared_key_with_bob = alice_ecdh.derive_shared_key(bob_pk);
    let shared_key_with_alice = bob_ecdh.derive_shared_key(alice_pk);

    assert(shared_key_with_bob == shared_key_with_alice);
}
