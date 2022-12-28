use std::cell::RefCell;

use magnus::{
    block::{block_given, Yield, YieldSplat, YieldValues},
    define_module, exception, function, method,
    prelude::*,
    scan_args::check_arity,
    Error, RArray, Value,
};

#[magnus::wrap(class = "Halton::Sequence", free_immediatly, size)]
struct Sequence(RefCell<halton::Sequence>);

impl Sequence {
    fn new(base: u8) -> Self {
        Self(RefCell::new(halton::Sequence::new(base)))
    }

    fn next(&self) -> Result<f64, Error> {
        match self.0.try_borrow_mut().unwrap().next() {
            Some(f) => Ok(f),
            None => Err(Error::new(
                exception::stop_iteration(),
                "iteration reached an end",
            )),
        }
    }

    fn skip(&self, n: usize) {
        self.0.try_borrow_mut().unwrap().nth(n);
    }

    fn remaining(&self) -> Option<usize> {
        self.0.try_borrow().unwrap().size_hint().1
    }
}

fn each_one(rb_self: Value, base: u8) -> Yield<impl Iterator<Item = f64>> {
    if !block_given() {
        return Yield::Enumerator(rb_self.enumeratorize("each_one", (base,)));
    }
    Yield::Iter(halton::Sequence::new(base))
}

fn each_pair(
    rb_self: Value,
    x_base: u8,
    y_base: u8,
) -> YieldValues<impl Iterator<Item = (f64, f64)>> {
    if !block_given() {
        return YieldValues::Enumerator(rb_self.enumeratorize("each_pair", (x_base, y_base)));
    }
    let seq_x = halton::Sequence::new(x_base);
    let seq_y = halton::Sequence::new(y_base);
    YieldValues::Iter(seq_x.zip(seq_y))
}

fn each_triple(
    rb_self: Value,
    x_base: u8,
    y_base: u8,
    z_base: u8,
) -> YieldValues<impl Iterator<Item = (f64, f64, f64)>> {
    if !block_given() {
        return YieldValues::Enumerator(
            rb_self.enumeratorize("each_triple", (x_base, y_base, z_base)),
        );
    }
    let seq_x = halton::Sequence::new(x_base);
    let seq_y = halton::Sequence::new(y_base);
    let seq_z = halton::Sequence::new(z_base);
    YieldValues::Iter(seq_x.zip(seq_y).zip(seq_z).map(|((x, y), z)| (x, y, z)))
}

fn each_many(
    rb_self: Value,
    args: &[Value],
) -> Result<YieldSplat<impl Iterator<Item = RArray>>, Error> {
    check_arity(args.len(), 1..)?;
    let bases = args
        .iter()
        .map(|v| v.try_convert())
        .collect::<Result<Vec<u8>, _>>()?;

    if !block_given() {
        return Ok(YieldSplat::Enumerator(
            rb_self.enumeratorize("each_many", args),
        ));
    }
    let mut seqs = bases
        .into_iter()
        .map(halton::Sequence::new)
        .collect::<Vec<_>>();
    let mut buffer = Vec::<Value>::with_capacity(seqs.len());
    Ok(YieldSplat::Iter(std::iter::from_fn(move || {
        buffer.clear();
        for seq in &mut seqs {
            if let Some(v) = seq.next() {
                buffer.push(v.into());
            } else {
                return None;
            }
        }
        Some(RArray::from_slice(&buffer))
    })))
}

#[magnus::init]
fn init() -> Result<(), Error> {
    let module = define_module("Halton")?;
    module.define_singleton_method("number", function!(halton::number, 2))?;
    module.define_singleton_method("each_one", method!(each_one, 1))?;
    module.define_singleton_method("each_pair", method!(each_pair, 2))?;
    module.define_singleton_method("each_triple", method!(each_triple, 3))?;
    module.define_singleton_method("each_many", method!(each_many, -1))?;
    let class = module.define_class("Sequence", Default::default())?;
    class.define_singleton_method("new", function!(Sequence::new, 1))?;
    class.define_method("next", method!(Sequence::next, 0))?;
    class.define_method("skip", method!(Sequence::skip, 1))?;
    class.define_method("remaining", method!(Sequence::remaining, 0))?;
    Ok(())
}
