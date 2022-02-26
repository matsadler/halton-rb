use std::cell::RefCell;

use magnus::{define_module, function, method, prelude::*, Error};

#[magnus::wrap(class = "Halton::Sequence", free_immediatly, size)]
struct Sequence(RefCell<halton::Sequence>);

impl Sequence {
    fn new(base: u8) -> Self {
        Self(RefCell::new(halton::Sequence::new(base)))
    }

    fn next(&self) -> Result<f64, Error> {
        match self.0.try_borrow_mut().unwrap().next() {
            Some(f) => Ok(f),
            None => Err(Error::stop_iteration("iteration reached an end")),
        }
    }

    fn skip(&self, n: usize) {
        self.0.try_borrow_mut().unwrap().nth(n);
    }

    fn remaining(&self) -> Option<usize> {
        self.0.try_borrow().unwrap().size_hint().1
    }
}

#[magnus::init]
fn init() -> Result<(), Error> {
    let module = define_module("Halton")?;
    module.define_singleton_method("number", function!(halton::number, 2));
    let class = module.define_class("Sequence", Default::default())?;
    class.define_singleton_method("new", function!(Sequence::new, 1));
    class.define_method("next", method!(Sequence::next, 0));
    class.define_method("skip", method!(Sequence::skip, 1));
    class.define_method("remaining", method!(Sequence::remaining, 0));
    Ok(())
}
