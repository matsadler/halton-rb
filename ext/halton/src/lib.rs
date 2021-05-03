use lazy_static::lazy_static;
use rutie::{
    class, methods, module, wrappable_struct, AnyObject, Class, Float, Integer, Module, NilClass,
    Object, VM,
};

macro_rules! unwrap_raise {
    ($val:expr) => {
        #[allow(clippy::redundant_closure)]
        $val.map_err(|e| VM::raise_ex(e))
            .expect("exception should have been raised")
    };
}

macro_rules! raise {
    ($class:ty, $($arg:tt)*) => {{
        VM::raise(Class::from_existing(stringify!($class)), &format!($($arg)*));
        unreachable!()
    }};
}

fn any_object_or_nil<T>(obj: Option<T>) -> AnyObject
where
    T: Into<AnyObject>,
{
    obj.map(Into::into)
        .unwrap_or_else(|| NilClass::new().into())
}

module!(Halton);

methods!(
    Halton,
    rtself,
    fn halton_number(base: Integer, index: Integer) -> Float {
        Float::new(halton::number(
            unwrap_raise!(base).to_u64() as u8,
            unwrap_raise!(index).to_u64() as usize,
        ))
    }
);

wrappable_struct!(halton::Sequence, SequenceWrapper, SEQUENCE_WRAPPER);

class!(Sequence);

methods!(
    Sequence,
    rtself,
    fn halton_sequence_new(base: Integer) -> AnyObject {
        let seq = halton::Sequence::new(unwrap_raise!(base).to_u64() as u8);
        Module::from_existing("Halton")
            .get_nested_class("Sequence")
            .wrap_data(seq, &*SEQUENCE_WRAPPER)
    },
    fn halton_sequence_next() -> Float {
        let seq = rtself.get_data_mut(&*SEQUENCE_WRAPPER);
        match seq.next() {
            Some(f) => Float::new(f),
            None => raise!(StopIteration, "iteration reached an end"),
        }
    },
    fn halton_sequence_skip(n: Integer) -> NilClass {
        let seq = rtself.get_data_mut(&*SEQUENCE_WRAPPER);
        seq.nth(unwrap_raise!(n).to_u64() as usize);
        NilClass::new()
    },
    fn halton_sequence_remaining() -> AnyObject {
        let seq = rtself.get_data(&*SEQUENCE_WRAPPER);
        any_object_or_nil(seq.size_hint().1.map(|i| Integer::new(i as i64)))
    }
);

#[allow(non_snake_case)]
#[no_mangle]
pub extern "C" fn Init_halton() {
    Module::new("Halton").define(|module| {
        module.def_self("number", halton_number);
        module
            .define_nested_class("Sequence", None)
            .define(|class| {
                class.def_self("new", halton_sequence_new);
                class.def("next", halton_sequence_next);
                class.def("skip", halton_sequence_skip);
                class.def("remaining", halton_sequence_remaining);
            });
    });
}
