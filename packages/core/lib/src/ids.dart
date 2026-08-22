/// A backend-agnostic identifier for a user.
///
/// This wraps the opaque string
/// issued by whichever authentication provider is in use —
/// for instance, a UUID under Supabase, a 28-character token under Firebase.
/// The domain layer never interprets the contents,
/// so swapping providers does not ripple outwards.
///
/// Being an extension type, this carries no runtime cost:
/// it erases to [String] once compiled, while still preventing a raw string
/// (or a [String]-based identifier of a different kind)
/// from being passed by mistake.
extension type const UserId(String value) {}

/// An email address, kept distinct from a plain [String] at the type level.
///
/// Note that this performs no validation — it exists to stop a password
/// or a display name being passed where an address is expected.
/// Should format checking become necessary, replace this with a class
/// exposing a factory that returns a `Result<Email>`;
/// extension types cannot reject their input.
extension type const Email(String value) {}
