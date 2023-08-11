use std::cell::RefCell;

use magnus::{
    block::{Yield, YieldSplat, YieldValues},
    function, method,
    prelude::*,
    Error, RArray, Value, Ruby
};

#[magnus::wrap(class = "Halton::Sequence", free_immediately, size)]
struct Sequence(RefCell<halton::Sequence>);

impl Sequence {
    fn new(base: u8) -> Self {
        Self(RefCell::new(halton::Sequence::new(base)))
    }

    fn next(ruby: &Ruby, rb_self: &Sequence) -> Result<f64, Error> {
        match rb_self.0.try_borrow_mut().unwrap().next() {
            Some(f) => Ok(f),
            None => Err(Error::new(
                ruby.exception_stop_iteration(),
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

    fn take(ruby: &Ruby, rb_self: &Sequence, n: usize) -> RArray {
        ruby.ary_from_iter(rb_self.0.try_borrow_mut().unwrap().clone().take(n))
    }
}

fn each_one(ruby: &Ruby, rb_self: Value, base: u8) -> Yield<impl Iterator<Item = f64>> {
    if !ruby.block_given() {
        return Yield::Enumerator(rb_self.enumeratorize("each_one", (base,)));
    }
    Yield::Iter(halton::Sequence::new(base))
}

fn each_pair(
    ruby: &Ruby,
    rb_self: Value,
    x_base: u8,
    y_base: u8,
) -> YieldValues<impl Iterator<Item = (f64, f64)>> {
    if !ruby.block_given() {
        return YieldValues::Enumerator(rb_self.enumeratorize("each_pair", (x_base, y_base)));
    }
    let seq_x = halton::Sequence::new(x_base);
    let seq_y = halton::Sequence::new(y_base);
    YieldValues::Iter(seq_x.zip(seq_y))
}

fn each_triple(
    ruby: &Ruby,
    rb_self: Value,
    x_base: u8,
    y_base: u8,
    z_base: u8,
) -> YieldValues<impl Iterator<Item = (f64, f64, f64)>> {
    if !ruby.block_given() {
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
    let ruby = unsafe { Ruby::get_unchecked() };
    ruby.check_arity(args.len(), 1..)?;
    let bases = args
        .iter()
        .map(|v| u8::try_convert(*v))
        .collect::<Result<Vec<u8>, _>>()?;

    if !ruby.block_given() {
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
                buffer.push(ruby.into_value(v));
            } else {
                return None;
            }
        }
        Some(ruby.ary_new_from_values(&buffer))
    })))
}

#[magnus::init]
fn init(ruby: &Ruby) -> Result<(), Error> {
    let module = ruby.define_module("Halton")?;
    module.define_singleton_method("number", function!(halton::number, 2))?;
    module.define_singleton_method("each_one", method!(each_one, 1))?;
    module.define_singleton_method("each_pair", method!(each_pair, 2))?;
    module.define_singleton_method("each_triple", method!(each_triple, 3))?;
    module.define_singleton_method("each_many", method!(each_many, -1))?;
    let class = module.define_class("Sequence", ruby.class_object())?;
    class.define_singleton_method("new", function!(Sequence::new, 1))?;
    class.define_method("next", method!(Sequence::next, 0))?;
    class.define_method("skip", method!(Sequence::skip, 1))?;
    class.define_method("remaining", method!(Sequence::remaining, 0))?;
    class.define_method("take", method!(Sequence::take, 1))?;
    Ok(())
}
